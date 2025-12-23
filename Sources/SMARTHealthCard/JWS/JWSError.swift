import Foundation

public enum JWSError: Error, CustomStringConvertible, LocalizedError {
    
    // A JWS should have three segments: header, payload, and signature.
    case invalidNumberOfSegments(Int)
	case invalidData
	
	public var description: String {
		switch self {
		case .invalidNumberOfSegments(let segments):
			return "The data format is invalid. Found \(segments) instead of 3 segments"
		case .invalidData:
			return "Invalid SMART Health Card data"
		}
	}
	
	public var errorDescription: String? {
		NSLocalizedString(description, comment: "JWSError")
	}
}
