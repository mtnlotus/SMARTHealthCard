//
//  SMARTHealthCard.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 11/15/25.
//

import Foundation

/**
  A SMART Health Card as defined by https://hl7.org/fhir/uv/smart-health-cards-and-links/.
 */
public struct HealthCardSet: Codable {
	
	public let verifiableCredential: [JWS]
	
	// TOOD
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.verifiableCredential = try container.decode([JWS].self, forKey: .verifiableCredential)
	}
	
	public init(verifiableCredential: [JWS]) {
		self.verifiableCredential = verifiableCredential
	}
	
	public init(from json: [String: Any]) throws {
		if let jwsStrings = json["verifiableCredential"] as? [String] {
			self.verifiableCredential = try jwsStrings.compactMap { try JWS(from: $0) }
		}
		else {
			self.verifiableCredential = []
		}
	}
	
}
