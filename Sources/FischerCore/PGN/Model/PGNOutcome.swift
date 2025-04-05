//
//  PGNOutcome.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

public enum PGNOutcome: String, CaseIterable {
    case win = "1-0"
    case loss = "0-1"
    case draw = "1/2-1/2"
    case undefined = "*"
}
