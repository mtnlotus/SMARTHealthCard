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
struct SMARTHealthCard: Codable {
	
	public let verifiableCredential: [JWS]
	
	public init(from json: [String: Any]) throws {
		if let jwsStrings = json["verifiableCredential"] as? [String] {
			self.verifiableCredential = try jwsStrings.compactMap { try JWS(from: $0) }
		}
		else {
			self.verifiableCredential = []
		}
	}
	
}
