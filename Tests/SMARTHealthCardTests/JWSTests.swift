import Testing
import Foundation
import ModelsR4

@testable import SMARTHealthCard

@Suite struct JWSTests {
	
	var testResourcesDirectory: String {
		"TestData"
	}
	
	/// Load SMART Health Card from a file.
	func loadSmartHealthCard(from fileName: String) throws -> [String: Any] {
		let filePath = "\(testResourcesDirectory)/\(fileName)"
		guard let fileURL = Foundation.Bundle.module.url(forResource: filePath, withExtension: "smart-health-card")
		else { throw TestError.failed("Cannot load test resources from: \(filePath)") }
							
		do {
			let cardData = try Data(contentsOf: fileURL)
			return try JSONSerialization.jsonObject(with: cardData, options: []) as! [String: Any]
		}
		catch {
			throw TestError.failed("Cannot parse SMART Health Card from: \(filePath)")
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
	
	@Test func verifySignature() async throws {
		let cardData = try loadSmartHealthCard(from: "example-00-e-file")
		let smartHealthCard = try SMARTHealthCard(from: cardData)
		let jws = smartHealthCard.verifiableCredential.first!
		
		#expect(try await jws.verifySignature() == true)
	}
}
