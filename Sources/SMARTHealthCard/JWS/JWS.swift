/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A struct that represents a JSON Web Signature (JWS).
*/

import Foundation

/**
  A JSON Web Signature as defined by https://tools.ietf.org/html/rfc7515.
 */
public struct JWS: Codable {
	
	static let smallestB64CharCode: UInt8 = 45
    
    public let header: String
    
    public let payloadString: String
    
    public let payload: Data
    
    public let signature: String
	
	public var compactSerialization: String {
		"\(header).\(payloadString).\(signature)"
	}
	
	public var numericSerialization: String {
		let intValues = compactSerialization.compactMap { $0.asciiValue }
			.map { $0 - JWS.smallestB64CharCode }
			.flatMap { [$0 / 10, $0 % 10] }
		
		let numericString = intValues.map { String($0) }.joined(separator: "")
		return numericString
	}
	
	public init(fromNumeric numericSerialization: String) throws {
		if numericSerialization.isEmpty || !numericSerialization.hasPrefix("shc:/") {
			throw JWSError.invalidData
		}
		// Trim "shc:/" prefix.
		let numericString = String(numericSerialization.trimmingPrefix("shc:/"))
		
		// Decoding the pairs of numerals yields a JWS serialization.
		let twoCharSubstrings = numericString.splitIntoChunks(ofLength: 2)
		let byteArray: [UInt8] = twoCharSubstrings.compactMap { UInt8($0) }.map { $0 + JWS.smallestB64CharCode }
		let jwsString = String(bytes: byteArray, encoding: .ascii) ?? ""
		
		try self.init(from: jwsString)
	}
	
    public init(from compactSerialization: String) throws {
		if compactSerialization.isEmpty {
			throw JWSError.invalidData
		}
        let (headerString, payloadString, signatureString) = try Self.split(compactSerialization: compactSerialization)
        
        let headerData = try Base64URL.decode(headerString)
        let jsonDecoder = JSONDecoder()
        let parsedHeader = try jsonDecoder.decode(JWSHeader.self, from: headerData)
        
        var payload = try Base64URL.decode(payloadString)
        if parsedHeader.zip == .deflate {
            payload = try payload.decompress()
        }
        
        self.init(header: headerString, payloadString: payloadString, payload: payload, signature: signatureString)
    }
    
    public init(header: String, payloadString: String, payload: Data, signature: String) {
        self.header = header
        self.payloadString = payloadString
        self.payload = payload
        self.signature = signature
    }
    
    private static func split(compactSerialization: String) throws -> (String, String, String) {
        let parts = compactSerialization.split(separator: ".").map { String($0) }
        guard parts.count == 3 else {
            throw JWSError.invalidNumberOfSegments(parts.count)
        }
        
        return (parts[0], parts[1], parts[2])
    }
}

public struct JWSHeader: Codable {
    
    public let alg: SignatureAlgorithm
    
    public let kid: String
    
    public let typ: String?
    
    public let zip: CompressionAlgorithm
}
