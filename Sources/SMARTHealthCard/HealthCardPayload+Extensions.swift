//
//  SMARTHealthCardPayload+Extensions.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/5/25.
//

import Foundation

public extension HealthCardPayload {
	
	var issuer: String {
		self.iss
	}
	
	var issueDate: Date? {
		self.nbf != nil ? Date(timeIntervalSince1970: self.nbf!) : nil
	}
	
	var expiresDate: Date? {
		self.exp != nil ? Date(timeIntervalSince1970: self.exp!) : nil
	}
	
}
