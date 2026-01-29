//
//  TrustedIssuer.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/10/25.
//

import SMARTHealthCard

public struct IssuerDirectory: Codable {
	public let participating_issuers: [TrustedIssuer]
}

public struct IssuerDirectorySnapshot: Codable {
	public let directory: String?
	public let time: String?
	public let issuerInfo: [IssuerInfo]
}

public struct IssuerInfo: Codable {
	public var issuer: TrustedIssuer
	public let keys: [JWK]?
	public let lastRetrieved: String?
	
	public init(issuer: TrustedIssuer, keys: [JWK]? = nil, lastRetrieved: String? = nil) {
		self.issuer = issuer
		self.keys = keys
		self.lastRetrieved = lastRetrieved
	}
}

public struct TrustedIssuer: Codable {
	public let iss: String
	public let canonical_iss: String?
	public let name: String
	public let website: String?
	public var isTrusted: Bool?
	
	public init(iss: String, canonical_iss: String? = nil, name: String, website: String? = nil, isTrusted: Bool = false) {
		self.iss = iss
		self.canonical_iss = canonical_iss
		self.name = name
		self.website = website
		self.isTrusted = isTrusted
	}
}

