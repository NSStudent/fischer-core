//
//  UCITests.swift
//  FischerCore
//
//  Created by Omar Megdadi on 13/4/25.
//

import Testing
@testable import FischerCore

final class UCITests {
    
    @Test("Iligal LAN Move")
    func testIligalMove() throws {
        let game = try Game(with: "K7/8/8/4p3/3P4/8/8/7k w - - 0 1")
        #expect(throws: FischerCoreError.illegalMove) {
            let move = try game.sanMove(from: "tests")
        }
    }
    
    @Test("LAN Pawn Capture move to San")
    func testLanPawnCapture() throws {
        let game = try Game(with: "K7/8/8/4p3/3P4/8/8/7k w - - 0 1")
        let move = try game.sanMove(from: "d4e5")
        let expectedMove = SANMove.san(
            SANMove.SANDefaultMove(
                kind: .pawn,
                from: .file(.d),
                isCapture: true,
                toSquare: .e5,
                promotion: nil,
                isCheck: false,
                isCheckmate: false
            )
        )
        #expect(
            move == expectedMove
        )
    }
    
    @Test("LAN Pawn avance move to San")
    func testPawnAvanceCapture() throws {
        let game = try Game(with: "K7/8/8/4p3/3P4/8/8/7k w - - 0 1")
        let move = try game.sanMove(from: "d4d5")
        let expectedMove = SANMove.san(
            SANMove.SANDefaultMove(
                kind: .pawn,
                from: nil,
                isCapture: false,
                toSquare: .d5,
                promotion: nil,
                isCheck: false,
                isCheckmate: false
            )
        )
        #expect(
            move == expectedMove
        )
    }
    
    @Test("Pawn doble move to San")
    func PawnDobleMove() async throws {
        let game = try Game(with: "4k3/8/8/8/8/8/4P3/4K3 w - - 0 1")
        let move = try game.sanMove(from: "e2e4")
        let expectedMove = SANMove.san(
            SANMove.SANDefaultMove(
                kind: .pawn,
                from: nil,
                isCapture: false,
                toSquare: .e4,
                promotion: nil,
                isCheck: false,
                isCheckmate: false
            )
        )
        #expect(
            move == expectedMove
        )
    }
    
    @Test("Kingside castling move to San")
    func kingsideCastlingMove() async throws {
        let game = try Game(with: "r3k2r/8/8/8/8/8/4P3/R3K2R w KQkq - 0 1")
        let move = try game.sanMove(from: "e1g1")
        let expectedMove = SANMove.kingsideCastling
        #expect(
            move == expectedMove
        )
    }
    
    @Test("Kingside castling black move to San")
    func kingsideCastlingBlackMove() async throws {
        let game = try Game(with: "r3k2r/8/8/8/8/8/4P3/R3K2R b KQkq - 0 1")
        let move = try game.sanMove(from: "e8g8")
        let expectedMove = SANMove.kingsideCastling
        #expect(
            move == expectedMove
        )
    }
    
    @Test("Queenside castling move to San")
    func queensideCastlingMove() async throws {
        let game = try Game(with: "r3k2r/8/8/8/8/8/4P3/R3K2R w KQkq - 0 1")
        let move = try game.sanMove(from: "e1c1")
        let expectedMove = SANMove.queensideCastling
        #expect(
            move == expectedMove
        )
    }
    
    @Test("Queenside castling Black move to San")
    func queensideCastlingBlackMove() async throws {
        let game = try Game(with: "r3k2r/8/8/8/8/8/4P3/R3K2R b KQkq - 0 1")
        let move = try game.sanMove(from: "e8c8")
        let expectedMove = SANMove.queensideCastling
        #expect(
            move == expectedMove
        )
    }
    
    
    @Test("white promotion to knight move to San")
    func promotionWhiteKnightMove() async throws {
        let game = try Game(with: "8/k6P/8/8/8/8/K6p/8 w - - 0 1")
        let move = try game.sanMove(from: "h7h8N")
        let expectedMove = SANMove.san(
            SANMove.SANDefaultMove(
                kind: .pawn,
                from: nil,
                isCapture: false,
                toSquare: .h8,
                promotion: SANMove.PromotionPiece.knight,
                isCheck: false,
                isCheckmate: false
            )
        )
        #expect(
            move == expectedMove
        )
    }

//
//    @Test
//    func testPromotion() {
//        let p = Position(fen: "8/P7/8/8/8/8/8/8 w - - 0 1")
//
//        let qPromotion = EngineLANParser.parse(move: "a7a8q", for: .white, in: p)
//        let promotedQueen = Piece(.queen, color: .white, square: .a8)
//        XCTAssertEqual(qPromotion?.promotedPiece, promotedQueen)
//
//        let rPromotion = EngineLANParser.parse(move: "a7a8r", for: .white, in: p)
//        let promotedRook = Piece(.rook, color: .white, square: .a8)
//        XCTAssertEqual(rPromotion?.promotedPiece, promotedRook)
//
//        let bPromotion = EngineLANParser.parse(move: "a7a8b", for: .white, in: p)
//        let promotedBishop = Piece(.bishop, color: .white, square: .a8)
//        XCTAssertEqual(bPromotion?.promotedPiece, promotedBishop)
//
//        let nPromotion = EngineLANParser.parse(move: "a7a8n", for: .white, in: p)
//        let promotedKnight = Piece(.knight, color: .white, square: .a8)
//        XCTAssertEqual(nPromotion?.promotedPiece, promotedKnight)
//    }
//
//    @Test
//    func testValidLANButInvalidMove() {
//        XCTAssertNil(EngineLANParser.parse(move: "a4b5", for: .white, in: .standard))
//        XCTAssertNil(EngineLANParser.parse(move: "f8b5", for: .black, in: .standard))
//    }
//
//    @Test
//    func testInvalidLAN() {
//        XCTAssertNil(EngineLANParser.parse(move: "bad move", for: .white, in: .standard))
//    }
}
