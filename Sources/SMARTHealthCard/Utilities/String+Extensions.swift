//
//  String+Extensions.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 11/19/25.
//

extension String {
	
	internal func splitIntoChunks(ofLength length: Int) -> [String] {
		guard length > 0 else { return [] } // Handle invalid length
		
		var result: [String] = []
		var currentIndex = self.startIndex
		
		while currentIndex < self.endIndex {
			let endIndexForChunk = self.index(currentIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
			let chunk = String(self[currentIndex..<endIndexForChunk])
			result.append(chunk)
			currentIndex = endIndexForChunk
		}
		return result
	}
	
}
