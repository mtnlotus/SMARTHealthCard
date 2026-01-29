//
//  Logger.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/22/25.
//

import OSLog

extension Logger {
	
//	static let bundleIdentifier = Bundle.module.bundleIdentifier!
	static let bundleIdentifier = "com.mtnlotus.SMARTHealthCard"
	
	/// Messages displayed to the user..
	static let messages = Logger(subsystem: bundleIdentifier, category: "messages")
	
	/// Logs related to SMART Health Card verification.
	static let verification = Logger(subsystem: bundleIdentifier, category: "verification")
	
	/// Logs the view cycles like a view that appeared.
	static let viewCycle = Logger(subsystem: bundleIdentifier, category: "viewcycle")

	/// All logs related to tracking and analytics.
	static let statistics = Logger(subsystem: bundleIdentifier, category: "statistics")
}
