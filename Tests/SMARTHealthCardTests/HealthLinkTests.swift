//
//  HealthLinkTests.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/28/25.
//

import Testing
import Foundation
import ModelsR4

@testable import SMARTHealthCard

@Suite struct HealthLinkTests {
	
	var testDataDirectory: String {
		"TestData"
	}
	
	/// Load SMART Health Card from a file.
	func loadSmartHealthCard(from fileName: String) throws -> [String: Any] {
		try loadJSONData(from: fileName, withExtension: "smart-health-card")
	}
	
	/// Load JSON data from a file.
	func loadJSONData(from fileName: String, withExtension fileExtension: String = "json") throws -> [String: Any] {
		let filePath = "\(testDataDirectory)/\(fileName)"
		guard let fileURL = Foundation.Bundle.module.url(forResource: filePath, withExtension: fileExtension)
		else { throw TestError.failed("Cannot load JSON file from: \(filePath).\(fileExtension)") }
		
		do {
			let jsonData = try Data(contentsOf: fileURL)
			return try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
		}
		catch {
			throw TestError.failed("Cannot parse JSON data from: \(filePath).\(fileExtension)")
		}
	}
	
	
	
}
