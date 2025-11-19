import Testing
import Foundation
import ModelsR4

@testable import SMARTHealthCard

@Suite struct SMARTHealthCardTests {
	
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
	
	/// Load String data from a file.
	func loadStringData(from fileName: String, withExtension fileExtension: String = "txt") throws -> String {
		let filePath = "\(testDataDirectory)/\(fileName)"
		guard let fileURL = Foundation.Bundle.module.url(forResource: filePath, withExtension: fileExtension)
		else { throw TestError.failed("Cannot load data file from: \(filePath).\(fileExtension)") }
							
		do {
			return try String(contentsOf: fileURL, encoding: .utf8)
		}
		catch {
			throw TestError.failed("Cannot parse String data from: \(filePath).\(fileExtension)")
		}
	}
	
	/**
	 Read SMART Health Card from a file.
	 https://hl7.org/fhir/uv/smart-health-cards-and-links/cards-specification.html#via-file-download
	 */
	@Test func parseHealthCard() async throws {
		let cardData = try loadSmartHealthCard(from: "example-00-e-file")
		#expect(cardData["verifiableCredential"] != nil)
		
		let smartHealthCard = try SMARTHealthCard(from: cardData)
		#expect(smartHealthCard.verifiableCredential.count == 1)
	}
	
	@Test func parsePayload() async throws {
		let cardData = try loadSmartHealthCard(from: "example-00-e-file")
		let smartHealthCard = try SMARTHealthCard(from: cardData)
		let payload = smartHealthCard.verifiableCredential.first!.payload
		
		let smartHealthCardPayload = try JSONDecoder().decode(SMARTHealthCardPayload.self, from: payload)
		#expect(smartHealthCardPayload.iss == "https://spec.smarthealth.cards/examples/issuer")
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?.count == 4)
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?[0].resource?.get() is Patient)
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?[1].resource?.get() is Immunization)
		
//		print(String(data: payload, encoding: .utf8)!)
	}
	
	@Test func parseQRCodePayload() async throws {
		let stringData = try loadStringData(from: "example-00-d-jws", withExtension: "txt")
		let jws = try JWS(from: stringData)
		let smartHealthCardPayload = try JSONDecoder().decode(SMARTHealthCardPayload.self, from: jws.payload)
		
		#expect(smartHealthCardPayload.iss == "https://spec.smarthealth.cards/examples/issuer")
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?.count == 4)
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?[0].resource?.get() is Patient)
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?[1].resource?.get() is Immunization)
	}
	
	@Test func jwsToNumericSerialization() async throws {
		let jwsString = try loadStringData(from: "example-00-d-jws", withExtension: "txt")
		let numericString = try loadStringData(from: "example-00-f-qr-code-numeric-value-0", withExtension: "txt").trimmingCharacters(in: .whitespacesAndNewlines)
		
		let jws = try JWS(from: jwsString)
		let numericSerialization = jws.numericSerialization
		#expect(numericSerialization == numericString)
	}
	
	@Test func jwsFromNumericSerialization() async throws {
		let jwsString = try loadStringData(from: "example-00-d-jws", withExtension: "txt")
		let numericString = try loadStringData(from: "example-00-f-qr-code-numeric-value-0", withExtension: "txt").trimmingCharacters(in: .whitespacesAndNewlines)
		
		let jws = try JWS(fromNumeric: numericString)
		let compactSerialization = jws.compactSerialization
		#expect(compactSerialization == jwsString)
	}
	
	@Test func parseNumericQRCodePayload() async throws {
		let numericString = try loadStringData(from: "example-00-f-qr-code-numeric-value-0", withExtension: "txt").trimmingCharacters(in: .whitespacesAndNewlines)
		let jws = try JWS(fromNumeric: numericString)
		let smartHealthCardPayload = try JSONDecoder().decode(SMARTHealthCardPayload.self, from: jws.payload)
		
		#expect(smartHealthCardPayload.iss == "https://spec.smarthealth.cards/examples/issuer")
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?.count == 4)
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?[0].resource?.get() is Patient)
		#expect(smartHealthCardPayload.vc.credentialSubject.fhirBundle?.entry?[1].resource?.get() is Immunization)
	}
	
	@Test func verifySignature() async throws {
		let cardData = try loadSmartHealthCard(from: "example-00-e-file")
		let smartHealthCard = try SMARTHealthCard(from: cardData)
		let jws = smartHealthCard.verifiableCredential.first!
		
		#expect(try await jws.verifySignature() == true)
	}
	
	@Test func ordinalValues() {
		let stringValue = "3"
		let intValues = stringValue.compactMap { $0.asciiValue }
			.map { $0 - JWS.smallestB64CharCode }
			.flatMap { [$0 / 10, $0 % 10] }
		
		let numericString = intValues.map { String($0) }.joined(separator: "")
		
		#expect(intValues == [0, 6])
		#expect(numericString == "06")
	}
	
}
