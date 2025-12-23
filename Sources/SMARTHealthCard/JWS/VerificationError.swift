//
//  VerificationError.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/4/25.
//

import Foundation

public enum VerificationError: Error, CustomStringConvertible, LocalizedError {
    case untrustedIssuer(String)
    case unableToParseIssuerURL(String)
    case failedToCreateUTF8DataFromString
	case noPublicKeyFound
	
	public var description: String {
		switch self {
			case .untrustedIssuer(let issuer):
			return "Untrusted issuer: \(issuer)"
		case .unableToParseIssuerURL(let issuer):
			return "Unable to parse issuer URL: \(issuer)"
		case .failedToCreateUTF8DataFromString:
			return "Failed to create data to verify JWS signature"
		case .noPublicKeyFound:
			return "Record verification failed: issuer public key not found"
		}
	}
	
	public var errorDescription: String? {
		NSLocalizedString(description, comment: "VerificationError")
	}
}
