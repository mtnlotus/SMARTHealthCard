//
//  VerificationError.swift
//  SMARTHealthCard
//
//  Created by David Carlson on 12/4/25.
//


public enum VerificationError: Error {
    case untrustedIssuer(String)
    case unableToParseIssuerURL(String)
    case failedToCreateUTF8DataFromString
}
