//
//  GameConvenienceTests.swift
//  FischerCore
//

import Testing
@testable import FischerCore

final class GameConvenienceTests {
    @Test("FEN placement extracts placement from full FEN or placement")
    func fenPlacement() {
        #expect(
            FEN.placement(from: "8/8/8/8/8/8/8/4K3 w - - 0 1")
            == "8/8/8/8/8/8/8/4K3"
        )
        #expect(FEN.placement(from: "8/8/8/8/8/8/8/4K3") == "8/8/8/8/8/8/8/4K3")
    }

    @Test("Game resolves physical board placement into a normal move")
    func resolvesPhysicalPlacementIntoNormalMove() throws {
        var next = Game()
        try next.execute(move: .e2 >>> .e4)

        let resolved = Game().resolvedMove(toPlacement: next.position.board.fen())

        #expect(resolved == ResolvedMove(move: .e2 >>> .e4))
    }

    @Test("Game resolves physical board placement into a promotion move")
    func resolvesPhysicalPlacementIntoPromotionMove() throws {
        let game = try Game(with: "8/k6P/8/8/8/8/K6p/8 w - - 0 1")
        var next = game
        try next.execute(move: .h7 >>> .h8, promotion: .knight)

        let resolved = game.resolvedMove(toPlacement: next.position.board.fen())

        #expect(resolved == ResolvedMove(move: .h7 >>> .h8, promotion: .knight))
        #expect(game.requiresPromotion(move: .h7 >>> .h8))
    }

    @Test("Game executes UCI moves including promotion")
    func executeUCIMove() throws {
        var game = try Game(with: "8/k6P/8/8/8/8/K6p/8 w - - 0 1")

        try game.execute(uci: "h7h8n")

        #expect(game.board[.h8] == Piece(knight: .white))
        #expect(throws: (any Error).self) {
            try game.execute(uci: "0000")
        }
    }

    @Test("Game exposes outcome when finished")
    func outcome() throws {
        var game = Game()

        try game.execute(move: .f2 >>> .f3)
        try game.execute(move: .e7 >>> .e5)
        try game.execute(move: .g2 >>> .g4)
        try game.execute(move: .d8 >>> .h4)

        #expect(game.outcome == .win(.black))
    }

    @Test("Game jumps through undo and redo history")
    func jumpToMove() throws {
        var game = Game()
        try game.execute(move: .e2 >>> .e4)
        try game.execute(move: .e7 >>> .e5)
        try game.execute(move: .g1 >>> .f3)

        game.jumpToMove(1)
        #expect(game.moveHistory.map(\.move) == [.e2 >>> .e4])

        game.fastForward()
        #expect(game.moveHistory.map(\.move) == [.e2 >>> .e4, .e7 >>> .e5, .g1 >>> .f3])

        game.rewindToStart()
        #expect(game.moveHistory.isEmpty)
    }

    @Test("Game returns structured SAN moves")
    func playedSANMoves() throws {
        var game = try Game(with: "rnbqkbnr/pppppppp/8/8/8/1P6/P1PPPPPP/RNBQKBNR b KQkq - 0 1")

        try game.execute(move: .g7 >>> .g6)
        try game.execute(move: .c1 >>> .b2)
        try game.execute(move: .f8 >>> .g7)

        let moves = try game.playedSANMoves()

        #expect(moves.map(\.moveNumber) == [1, 2, 2])
        #expect(moves.map(\.color) == [.black, .white, .black])
        #expect(moves.map(\.san) == ["g6", "Bb2", "Bg7"])
        #expect(moves.map(\.move) == [.g7 >>> .g6, .c1 >>> .b2, .f8 >>> .g7])
    }
}
