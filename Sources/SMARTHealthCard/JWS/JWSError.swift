/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An error relating to handling a JSON Web Signature (JWS).
*/

public enum JWSError: Error {
    
    // A JWS should have three segments: header, payload, and signature.
    case invalidNumberOfSegments(Int)
	case invalidData
	
	public var description: String {
		switch self {
		case .invalidNumberOfSegments(let segments):
			return "The data format is invalid. Found \(segments) instead of 3 segments."
		case .invalidData:
			return "Invalid SMART Health Card data."
		}
	}
}
