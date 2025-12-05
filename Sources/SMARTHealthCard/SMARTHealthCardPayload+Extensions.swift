//
//  SMARTHealthCardPayload+Extensions.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/5/25.
//

import Foundation

public extension SMARTHealthCardPayload {
	
	public var issuer: String {
		self.iss
	}
	
	public var issueDate: Date? {
		self.nbf != nil ? Date(timeIntervalSince1970: self.nbf!) : nil
	}
	
	public var expiresDate: Date? {
		self.exp != nil ? Date(timeIntervalSince1970: self.exp!) : nil
	}
	
}
