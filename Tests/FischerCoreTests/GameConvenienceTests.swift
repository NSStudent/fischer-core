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

    @Test("Game exposes stable board pieces for UI identity")
    func boardPiecesExposeStableIdentity() throws {
        var game = Game()
        let initialID = try #require(game.pieceID(at: .e2))

        try game.execute(move: .e2 >>> .e4)

        #expect(game.pieceID(at: .e2) == nil)
        #expect(game.pieceID(at: .e4) == initialID)
        #expect(game.boardPieces.contains(Game.BoardPiece(id: initialID, piece: Piece(pawn: .white), square: .e4)))
    }

    @Test("Game restores board piece identity across capture undo and redo")
    func boardPieceIdentitySurvivesCaptureUndoRedo() throws {
        var game = try Game(with: "8/8/8/3p4/4P3/8/8/4K2k w - - 0 1")
        let movingID = try #require(game.pieceID(at: .e4))
        let capturedID = try #require(game.pieceID(at: .d5))

        try game.execute(move: .e4 >>> .d5)
        #expect(game.pieceID(at: .d5) == movingID)

        game.undoMove()
        #expect(game.pieceID(at: .e4) == movingID)
        #expect(game.pieceID(at: .d5) == capturedID)

        let didRedo = game.redoMove()
        #expect(didRedo)
        #expect(game.pieceID(at: .d5) == movingID)
    }

    @Test("Game moves rook identity when castling")
    func boardPieceIdentityMovesRookWhenCastling() throws {
        var game = try Game(with: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
        let kingID = try #require(game.pieceID(at: .e1))
        let rookID = try #require(game.pieceID(at: .h1))

        try game.execute(move: .e1 >>> .g1)

        #expect(game.pieceID(at: .g1) == kingID)
        #expect(game.pieceID(at: .f1) == rookID)

        game.undoMove()
        #expect(game.pieceID(at: .e1) == kingID)
        #expect(game.pieceID(at: .h1) == rookID)
    }

    @Test("Game removes and restores captured identity for en passant")
    func boardPieceIdentityHandlesEnPassant() throws {
        var game = try Game(with: "8/8/8/3pP3/8/8/8/4K2k w - d6 0 1")
        let movingID = try #require(game.pieceID(at: .e5))
        let capturedID = try #require(game.pieceID(at: .d5))

        try game.execute(move: .e5 >>> .d6)

        #expect(game.pieceID(at: .d6) == movingID)
        #expect(game.pieceID(at: .d5) == nil)

        game.undoMove()
        #expect(game.pieceID(at: .e5) == movingID)
        #expect(game.pieceID(at: .d5) == capturedID)
    }

    @Test("Game keeps pawn identity when promoting")
    func boardPieceIdentitySurvivesPromotion() throws {
        var game = try Game(with: "8/k6P/8/8/8/8/K6p/8 w - - 0 1")
        let pawnID = try #require(game.pieceID(at: .h7))

        try game.execute(move: .h7 >>> .h8, promotion: .knight)

        #expect(game.pieceID(at: .h8) == pawnID)
        #expect(game.boardPieces.contains(Game.BoardPiece(id: pawnID, piece: Piece(knight: .white), square: .h8)))
    }

    @Test("Game equality is stable for equivalent initial games")
    func gameEqualityIsStableForEquivalentInitialGames() {
        #expect(Game() == Game())
    }
}
