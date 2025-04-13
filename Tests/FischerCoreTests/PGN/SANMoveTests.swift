//
//  SANMoveTests.swift
//  FischerCore
//
//  Created by Omar Megdadi on 13/4/25.
//

import Testing
@testable import FischerCore
import Parsing

class SANMoveTests {
    @Test("validate all kind of promotions")
    func testPromotions() {
        let result = SANMove.PromotionPiece.allCases.map(\.kind.name)
        #expect(result == ["knight", "bishop", "rook", "queen"])
    }
}
