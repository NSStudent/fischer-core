//
//  PGNTagTests.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Testing
@testable import FischerCore
import Parsing

class PGNTagTests {
    @Test()
    func example() {
        #expect(PGNTag(rawValue: "Fen") != PGNTag(rawValue: "Event"))
    }
}
