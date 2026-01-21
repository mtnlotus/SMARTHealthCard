//
//  HealthLinkManifest.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/28/25.
//

import Foundation
import ModelsR4

/**
	SMART Health Link Manifest
	Defined by https://hl7.org/fhir/uv/smart-health-cards-and-links/.
 */
public struct HealthLinkManifest: Codable {
	
	public struct ManifestFile: Codable {
		
		public let contentType: String
		
		public let location: String?
		
		public let embedded: String?
		
		public let lastUpdated: DateTime?
		
	}
	
	
	/// FHIR.Base
	public let id: String?
	
	/// FHIR.Base
	public let `extension`: [Extension]?
	
	/// Indicates whether files may be changed in the future. Values are: finalized|can-change|no-longer-valid
	public let status: String?
	
	/// Property containing a List resource with metadata related to contained files.
	public let list: List?
	
	/// Object containing metadata related to one or more contained files.
	public let files: [ManifestFile]?
}

