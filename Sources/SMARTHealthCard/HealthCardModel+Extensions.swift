//
//  HealthCardModel+Extensions.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 1/28/26.
//

import Foundation
import class ModelsR4.Resource

public extension HealthCardModel {
	
	public var issueDate: Date? {
		healthCardPayload?.issueDate
	}
	
	public var expiresDate: Date? {
		healthCardPayload?.expiresDate
	}
	
	public var issuerName: String {
		guard let iss = healthCardPayload?.iss
		else { return "Unknown Issuer" }
		
		let issuer = trustManager?.issuer(iss: iss)?.issuer
		return issuer?.name ?? URL(string: iss)?.host() ?? iss
	}
	
	public var fhirResources: [Resource] {
		healthCardPayload?.vc.credentialSubject.fhirBundle?.entry?.compactMap { $0.resource?.get() } ?? []
	}
	
}
