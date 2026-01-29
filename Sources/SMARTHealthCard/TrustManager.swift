//
//  TrustManager.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/10/25.
//

import SwiftUI
import OSLog

@Observable
public class TrustManager {
	
	public init() { }
	
	/// Directories are file names that can be found in Bundle.main resources.
	/// Bundle.main.url(forResource: fileName, withExtension: "json")
	private var issuerDirectories: [String] = []
	
	public func addIssuerDirectories(fileNames: [String]) async throws {
		issuerDirectories.append(contentsOf: fileNames)
		try await loadIssuerDirectories()
	}
	
	/// key = iss, value = IssuerInfo
	public private(set) var issuerMap: [String: IssuerInfo] = [:]
	
	/// key = iss, value = Bool
	public private(set) var cachedVerification: [String: Bool] = [:]
	
	public func cachedVerification(iss: String?) -> Bool? {
		guard let iss = iss else { return nil }
		return cachedVerification[iss]
	}
	
	public func addCachedVerification(iss: String, isValid: Bool) {
		cachedVerification[iss] = isValid
	}
	
	public func issuer(iss: String?) -> IssuerInfo? {
		iss != nil ? issuerMap[iss!] : nil
	}
	
	public func issuerName(iss: String?) -> String? {
		if let iss = iss, let issuerInfo = issuerMap[iss] {
			return issuerInfo.issuer.name ?? URL(string: iss)?.host() ?? iss
		}
		return nil
	}
	
	public func isTrusted(iss: String?) -> Bool {
		if let iss = iss, let issuerInfo = issuerMap[iss], issuerInfo.issuer.isTrusted == true {
			return true
		}
		return false
	}
	
	public func addIssuer(_ issuerInfo: IssuerInfo) {
		issuerMap[issuerInfo.issuer.iss] = issuerInfo
		if let canonical_iss = issuerInfo.issuer.canonical_iss {
			issuerMap[canonical_iss] = issuerInfo
		}
	}
	
	func loadIssuerDirectories() async throws {
		for directoryFile in issuerDirectories {
			try await loadIssuerDirectory(fileName: directoryFile)
		}
	}
	
	func loadIssuerDirectory(fileName: String) async throws {
		guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json")
		else {
			Logger.verification.error("Failed to read Issuer Directory file from app bundle.")
			//TODO: throw error
			return
		}
		
		let issuerDirectory = try JSONDecoder().decode(IssuerDirectorySnapshot.self, from: try! Data(contentsOf: fileURL))
		for var issuerInfo in issuerDirectory.issuerInfo ?? [] {
			issuerInfo.issuer.isTrusted = true
			addIssuer(issuerInfo)
		}
		
		Logger.statistics.info("Loaded Issuer Directory from '\(fileName)' with \(issuerDirectory.issuerInfo.count ?? 0) entries.")
	}
	
}
