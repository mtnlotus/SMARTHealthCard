//
//  HealthCardModel+Extensions.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 1/28/26.
//

import Foundation
import protocol ModelsR4.Resource

public extension HealthCardModel {
	
	var issueDate: Date? {
		healthCardPayload?.issueDate
	}
	
	var expiresDate: Date? {
		healthCardPayload?.expiresDate
	}
	
	var issuerName: String {
		guard let iss = healthCardPayload?.iss
		else { return "Unknown Issuer" }
		
		let issuer = trustManager?.issuer(iss: iss)?.issuer
		return issuer?.name ?? URL(string: iss)?.host() ?? iss
	}
	
	var fhirResources: [any Resource] {
		healthCardPayload?.vc.credentialSubject.fhirBundle?.entry?.compactMap { $0.resource?.get() } ?? []
	}
	
}
