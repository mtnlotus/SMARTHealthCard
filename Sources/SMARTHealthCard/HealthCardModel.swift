//
//  HealthCardModel.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 11/19/25.
//

import CoreImage.CIFilterBuiltins
import CryptoKit
import SwiftUI
import class ModelsR4.Resource
import class ModelsR4.Bundle
import OSLog

/**
 A HealthCardModel represents one JWS entry within a HealthCardSet verifiableCredential array.
 */
@MainActor @Observable public class HealthCardModel {
	
	public var trustManager: TrustManager? {
		didSet {
			if trustManager != nil {
				verifySignature()
			}
		}
	}
	
	public init(trustManager: TrustManager? = nil) {
		self.trustManager = trustManager
	}

	public init(numericSerialization: String?, trustManager: TrustManager? = nil) {
		self.trustManager = trustManager
		self.numericSerialization = numericSerialization
	}
	
	public init(compactSerialization: String?, trustManager: TrustManager? = nil) {
		self.trustManager = trustManager
		self.compactSerialization = compactSerialization
	}
	
	/// JWS character size, where each character is represented by 2 digits.
	public var jwsCharacterCount: Int {
		if let numericData = numericSerialization {
			let dataString = String(numericData.trimmingPrefix("shc:/"))
			let characterCount: Int = dataString.count / 2
			return characterCount
		}
		return 0
	}
	
	public func clear() {
		clearData()
		clearMessages()
	}
	
	func clearData() {
		jws = nil
		healthCardPayload = nil
		jwsHeader = nil
		hasVerifiedSignature = nil
	}
	
	func clearMessages() {
		messages = []
	}
	
	public var compactSerialization: String? {
		didSet {
			clearMessages()
			do {
				if let data = compactSerialization {
					let jws = try JWS(from: data)
					self.jws = jws
				}
				else {
					clearData()
				}
			}
			catch {
				addMessage(error)
			}
		}
	}
	
	public var numericSerialization: String? {
		didSet {
			clearMessages()
			do {
				if let data = numericSerialization {
					let jws = try JWS(fromNumeric: data)
					self.jws = jws
				}
				else {
					clearData()
				}
			}
			catch {
				addMessage(error)
			}
		}
	}
	
	public var qrCodeImage: UIImage? {
		if let qrData = jws?.numericSerialization.data(using: .utf8) {
			let context = CIContext()
			let qrCodeGenerator = CIFilter.qrCodeGenerator()
			qrCodeGenerator.message = qrData
			qrCodeGenerator.correctionLevel = "L"
			 
			if let outputImage = qrCodeGenerator.outputImage {
				if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
					return UIImage(cgImage: cgImage)
				}
			}
		}
		return nil
	}
	
	public var qrCodeImageAsPNG: Data? {
		qrCodeImage?.pngData()
	}
	
	public private(set) var jws: JWS? {
		didSet {
			do {
				if let jws = jws {
					self.jwsHeader = try JSONDecoder().decode(JWSHeader.self, from: Base64URL.decode(jws.header))
					self.healthCardPayload = try JSONDecoder().decode(HealthCardPayload.self, from: jws.payload)
				}
			}
			catch {
				Logger.statistics.error("Failed to parse SMART Health Card header or payload: \(error)")
			}
		}
	}
	
	public private(set) var jwsHeader: JWSHeader?
	
	public private(set) var healthCardPayload: HealthCardPayload? {
		didSet {
			if healthCardPayload != nil {
//				Logger.statistics.debug("Completed parsing SMART Health Card, found \(self.fhirResources.count) FHIR resources")
				try? verifySignatureFromDirectory()
			}
		}
	}
	
	public private(set) var hasVerifiedSignature: Bool?
	
	public private(set) var messages: [ErrorMessage] = []
	
	public func addMessage(_ message: String) {
		self.messages.append(.init(message: message))
	}
	public func addMessage(_ error: Error) {
		self.messages.append(.init(error: error))
	}
	
	private func verifySignature() -> Bool? {
		guard hasVerifiedSignature == nil else { return hasVerifiedSignature! }
		do {
			// First, check cached URL verification
			hasVerifiedSignature = trustManager?.cachedVerification(iss: healthCardPayload?.iss)
			
			// Second, try to verify issuer using cached public keys from a trusted directory.
			hasVerifiedSignature = try verifySignatureFromDirectory()
			
			// If not found, try to fetch key from issuer URL.
			if hasVerifiedSignature == nil {
				Task {
					hasVerifiedSignature = try await verifySignatureFromURL()
				}
			}
			
			return hasVerifiedSignature
		}
		catch {
			self.hasVerifiedSignature = false
			addMessage(error)
			return hasVerifiedSignature
		}
	}
	
	private func verifySignatureFromDirectory() throws -> Bool? {
		guard hasVerifiedSignature == nil else { return hasVerifiedSignature! }
		guard let payload = healthCardPayload,
			  let issuerInfo = trustManager?.issuer(iss: payload.iss),
			  let header = jwsHeader
		else { return nil }
		
		if let signingKey: JWK = issuerInfo.keys?.first(where: { $0.kid == header.kid }) {
			let isValid = try signatureIsValid(signingKey: signingKey)
			Logger.statistics.debug("Found key in directory for issuer URL: \(payload.iss), signatureIsValid: \(isValid)")
			return isValid
		}
		Logger.statistics.debug("Key not found in directory for issuer URL: \(payload.iss)")
		return nil
	}
	
	private func verifySignatureFromURL() async throws -> Bool? {
		guard hasVerifiedSignature == nil else { return hasVerifiedSignature! }
		guard let payload = healthCardPayload, let header = jwsHeader else {
			return nil
		}
		
		// The standard URL to locate an issuer's signing public keys is
		// constructed by appending `/.well-known/jwks.json` to
		// the issuer's identifier.
		let urlString = payload.iss + "/.well-known/jwks.json"
		guard let url = URL(string: urlString) else {
			throw VerificationError.unableToParseIssuerURL(urlString)
		}
		
		let signingKey: JWK
		do {
			let configuration = URLSessionConfiguration.ephemeral
			configuration.timeoutIntervalForResource = 5.0
			let session = URLSession(configuration: configuration)
			let (data, _) = try await session.data(from: url, delegate: nil)
			let keySet = try JSONDecoder().decode(JWKSet.self, from: data)
			signingKey = try keySet.key(with: header.kid)
			
		}
		catch {
			throw VerificationError.noPublicKeyFound
		}
		
		let isValid = try signatureIsValid(signingKey: signingKey)
		trustManager?.addCachedVerification(iss: payload.iss, isValid: isValid)
		Logger.statistics.debug("Fetched issuer key from URL: \(payload.iss), signatureIsValid: \(isValid)")
		return isValid
	}
	
	private func signatureIsValid(signingKey: JWK) throws -> Bool {
		guard let jws = jws else {
			return false
		}
		let headerAndPayloadString = jws.header + "." + jws.payloadString
		guard let message = headerAndPayloadString.data(using: .utf8) else {
			throw VerificationError.failedToCreateUTF8DataFromString
		}
		
		let signingPublicKey = try signingKey.asP256PublicKey()
		let decodedSignature = try Base64URL.decode(jws.signature)
		let parsedECDSASignature = try P256.Signing.ECDSASignature(rawRepresentation: decodedSignature)
		return signingPublicKey.isValidSignature(parsedECDSASignature, for: message)
	}
}

