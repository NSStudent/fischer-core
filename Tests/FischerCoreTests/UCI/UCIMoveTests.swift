//
//  UCIMoveTests.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/11/25.
//

import Testing
@testable import FischerCore

final class UCIMoveTests {
    
    @Test("null move")
    func null_move() throws {
        let nullMoveString = "0000"
        let uciMoveParser = UCIMoveParser()
        let result = try uciMoveParser.parse(nullMoveString)
        #expect(result == .nullMove)
    }
    
    @Test("legar move")
    func legal_move() throws {
        let moveString = "e4e5"
        let uciMoveParser = UCIMoveParser()
        let result = try uciMoveParser.parse(moveString)
        let expected = UCIMove.move(UCIMoveValue(start: .e4, end: .e5, promotion: nil))
        #expect(result == expected)
    }
}
