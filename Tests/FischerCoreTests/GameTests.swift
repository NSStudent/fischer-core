import Testing
@testable import FischerCore

final class GameTests {

    @Test("Game Initialization")
    func testGameInitialization() {
        let game = Game()
        #expect(game.board == Board())
        #expect(game.playerTurn == .white)
        #expect(game.castlingRights == .all)
        #expect(game.halfmoves == 0)
        #expect(game.fullmoves == 1)
    }

    @Test("Game Copying")
    func testGameCopying() {
        let game = Game()
        let copy = game.copy()
        #expect(copy.board == game.board)
        #expect(copy.playerTurn == game.playerTurn)
        #expect(copy.castlingRights == game.castlingRights)
        #expect(copy.halfmoves == game.halfmoves)
        #expect(copy.fullmoves == game.fullmoves)
    }

    @Test("Game Legal Move Execution")
    func testLegalMoveExecution() throws {
        var game = Game()
        let move = Move(start: .e2, end: .e4)
        try game.execute(move: move)
        #expect(game.board[.e4] == Piece(pawn: .white))
        #expect(game.board[.e2] == nil)
        #expect(game.playerTurn == .black)
    }

    @Test("Game Illegal Move Execution")
    func testIllegalMoveExecution() throws {
        var game = Game()
        let move = Move(start: .e2, end: .e5) // Illegal move (too far)
        #expect(throws: (any Error).self) {
          try game.execute(move: move)
        }
    }

    @Test("Game Move History")
    func testMoveHistory() throws {
        var game = Game()
        let move1 = Move(start: .e2, end: .e4)
        let move2 = Move(start: .d7, end: .d5)
        try game.execute(move: move1)
        try game.execute(move: move2)
        #expect(game.moveHistory.count == 2)
    }

    @Test("Game Undo Move")
    func testUndoMove() throws {
        var game = Game()
        let move = Move(start: .e2, end: .e4)
        try game.execute(move: move)
        let undoneMove = game.undoMove()
        #expect(undoneMove == move)
        #expect(game.board[.e4] == nil)
        #expect(game.board[.e2] == Piece(pawn: .white))
        #expect(game.playerTurn == .white)
    }

    @Test("Game Outcome Detection")
    func testGameOutcome() throws {
        var game = Game()
        // Simulate a fool’s mate (fastest checkmate)
        try game.execute(move: Move(start: .f2, end: .f3))
        try game.execute(move: Move(start: .e7, end: .e5))
        try game.execute(move: Move(start: .g2, end: .g4))
        try game.execute(move: Move(start: .d8, end: .h4)) // Checkmate
        
        #expect(game.isFinished)
    }

    @Test("Game San Representation")
    func testSanRepresentation() throws {
        var game = Game()
        try game.execute(move: Move(start: .e2, end: .e4))
        try game.execute(move: Move(start: .e7, end: .e5))
        let san = game.sanRepresentation()
        #expect(san.contains("1.e4 e5"))
    }

    @Test("Game From FEN")
    func testGameFromFEN() throws {
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        let game = try Game(with: fen)
        #expect(game.board == Board())
        #expect(game.playerTurn == .white)
        #expect(game.castlingRights == .all)
        #expect(game.halfmoves == 0)
        #expect(game.fullmoves == 1)
    }

    @Test("Game Available Moves")
    func testAvailableMoves() {
        let game = Game()
        let moves = game.availableMoves()
        #expect(!moves.isEmpty)
    }

    @Test("Game Execute Move - Pawn Advance")
    func testExecuteMovePawnAdvance() throws {
        var game = Game()
        let move = Move(start: .e2, end: .e4)
        try game.execute(move: move)
        #expect(game.board[.e4] == Piece(pawn: .white))
        #expect(game.board[.e2] == nil)
        #expect(game.playerTurn == .black)
    }

    @Test("Game Execute Move - Knight Move")
    func testExecuteMoveKnight() throws {
        var game = Game()
        let move = Move(start: .g1, end: .f3)
        try game.execute(move: move)
        #expect(game.board[.f3] == Piece(knight: .white))
        #expect(game.board[.g1] == nil)
        #expect(game.playerTurn == .black)
    }

    @Test("Game Execute Move - Castling Kingside")
    func testExecuteMoveCastlingKingside() throws {
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = try Game(with: fen)

        let move = Move(castle: .white, direction: .right)
        try game.execute(move: move)

        #expect(game.board[.g1] == Piece(king: .white))
        #expect(game.board[.f1] == Piece(rook: .white))
        #expect(game.board[.e1] == nil)
        #expect(game.board[.h1] == nil)
        #expect(game.playerTurn == .black)
    }

    @Test("Game Execute Move - Capture")
    func testExecuteMoveCapture() throws {
        let fen = "rnbqkbnr/pppp1ppp/8/4p3/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 1"
        var game = try Game(with: fen)

        let move = Move(start: .d4, end: .e5) // Captura del peón en e5
        try game.execute(move: move)

        #expect(game.board[.e5] == Piece(pawn: .white))
        #expect(game.board[.d4] == nil)
        #expect(game.playerTurn == .black)
    }

    @Test("Game Undo Move - Simple Pawn Move")
    func testUndoMoveSimplePawnMove() throws {
        var game = Game()
        let move = Move(start: .e2, end: .e4)
        try game.execute(move: move)
        let undoneMove = game.undoMove()
        #expect(undoneMove == move)
        #expect(game.board[.e4] == nil)
        #expect(game.board[.e2] == Piece(pawn: .white))
        #expect(game.playerTurn == .white)
    }

    @Test("Game Undo Move - Castling")
    func testUndoMoveCastling() throws {
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        var game = try Game(with: fen)

        let move = Move(castle: .white, direction: .right)
        try game.execute(move: move)
        let undoneMove = game.undoMove()

        #expect(undoneMove == move)
        #expect(game.board[.e1] == Piece(king: .white))
        #expect(game.board[.h1] == Piece(rook: .white))
        #expect(game.board[.f1] == nil)
        #expect(game.board[.g1] == nil)
        #expect(game.playerTurn == .white)
    }
}
