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
        try game.execute(move: Move(start: .f2, end: .f3))
        try game.execute(move: Move(start: .e7, end: .e5))
        try game.execute(move: Move(start: .g2, end: .g4))
        try game.execute(move: Move(start: .d8, end: .h4)) // Checkmate
        
        #expect(game.isFinished)
    }

    @Test("Game San Representation")
    func testSanRepresentation() throws {
        var game = Game()

        try game.execute(move: Move(start: .b2, end: .b3))
        try game.execute(move: Move(start: .g7, end: .g6))
        try game.execute(move: Move(start: .c1, end: .b2))
        try game.execute(move: Move(start: .f8, end: .g7))
        try game.execute(move: Move(start: .b1, end: .c3))
        try game.execute(move: Move(start: .g8, end: .f6))
        try game.execute(move: Move(start: .e2, end: .e4))
        try game.execute(move: Move(start: .e8, end: .g8))
        try game.execute(move: Move(start: .d1, end: .e2))
        try game.execute(move: Move(start: .f6, end: .e4))
        try game.execute(move: Move(start: .e1, end: .c1))

        let san = game.sanRepresentation()
        #expect(san == "1.b3 g6 2.Bb2 Bg7 3.Nc3 Nf6 4.e4 O-O 5.Qe2 Nxe4 6.O-O-O")
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
    
    @Test("Game position Fen")
    func testPositionFen() throws {
        let fen = "rnbqkbnr/ppppp1pp/8/4Pp2/8/8/PPPP1PPP/RNBQKBNR w KQkq f6 0 1"
        let game = try Game(with: fen)
        let game2 = game
        #expect(game.position.fen() == fen)
        #expect(game2.position == game.position)
        #expect(game2.position.description == "Position(\(fen))")
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
    
    @Test("Game Outcome - Win")
    func testGameOutcomeWin() {
        let whiteWin = Game.Outcome.win(.white)
        let blackWin = Game.Outcome.win(.black)

        #expect(whiteWin.isWin)
        #expect(!whiteWin.isDraw)
        #expect(whiteWin.winColor == .white)
        #expect(whiteWin.description == "1-0")

        #expect(blackWin.isWin)
        #expect(!blackWin.isDraw)
        #expect(blackWin.winColor == .black)
        #expect(blackWin.description == "0-1")
    }

    @Test("Game Outcome - Draw")
    func testGameOutcomeDraw() {
        let draw = Game.Outcome.draw

        #expect(draw.isDraw)
        #expect(!draw.isWin)
        #expect(draw.winColor == nil)
        #expect(draw.description == "1/2-1/2")
    }

    @Test("Game Outcome - Initialization from String")
    func testGameOutcomeInitFromString() {
        #expect(Game.Outcome("1-0") == .win(.white))
        #expect(Game.Outcome("0-1") == .win(.black))
        #expect(Game.Outcome("1/2-1/2") == .draw)
        #expect(Game.Outcome("invalid") == nil)
    }

    @Test("Game Outcome - Value for Player")
    func testGameOutcomeValueForPlayer() {
        let whiteWin = Game.Outcome.win(.white)
        let blackWin = Game.Outcome.win(.black)
        let draw = Game.Outcome.draw

        #expect(whiteWin.value(for: .white) == 1.0)
        #expect(whiteWin.value(for: .black) == 0.0)
        #expect(blackWin.value(for: .white) == 0.0)
        #expect(blackWin.value(for: .black) == 1.0)
        #expect(draw.value(for: .white) == 0.5)
        #expect(draw.value(for: .black) == 0.5)
    }
    
    @Test("ExecutionError - Missing Piece Message")
    func testExecutionErrorMissingPieceMessage() {
        let error = Game.ExecutionError.missingPiece(.e4)
        #expect(error.message == "Missing piece: e4")
    }
    
    @Test("ExecutionError - Illegal Move Message")
    func testExecutionErrorIllegalMoveMessage() {
        let board = Board()
        let move = Move(start: .e2, end: .e5)
        let error = Game.ExecutionError.illegalMove(move, .white, board)
        #expect(error.message == "Illegal move: \(move) for white on \(board)")
    }
    
    @Test("ExecutionError - Invalid Promotion Message")
    func testExecutionErrorInvalidPromotionMessage() {
        let error = Game.ExecutionError.invalidPromotion(.king)
        #expect(error.message == "Invalid promoton: king")
    }
    
    @Test
    func testCapture() throws {
        let position = Position(fen: "K7/8/8/4p3/3P4/8/8/7k w - - 0 1")!
        let move = try position.sanMove(from: "d4e5")
        
        #expect(
            move == .san(
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
        )
        
    }
    
//    @Test
//    func testCastling() {
//        let p1 = Position(fen: "8/8/8/8/8/8/8/4K2R w KQ - 0 1")!
//        let wShortCastle = EngineLANParser.parse(move: "e1g1", for: .white, in: p1)
//        XCTAssertEqual(wShortCastle?.result, .castle(.wK))
//        
//        let p2 = Position(fen: "8/8/8/8/8/8/8/R3K3 w KQ - 0 1")!
//        let wLongCastle = EngineLANParser.parse(move: "e1c1", for: .white, in: p2)
//        XCTAssertEqual(wLongCastle?.result, .castle(.wQ))
//        
//        let p3 = Position(fen: "4k2r/8/8/8/8/8/8/8 b kq - 0 1")!
//        let bShortCastle = EngineLANParser.parse(move: "e8g8", for: .black, in: p3)
//        XCTAssertEqual(bShortCastle?.result, .castle(.bK))
//        
//        let p4 = Position(fen: "r3k3/8/8/8/8/8/8/8 b kq - 0 1")!
//        let bLongCastle = EngineLANParser.parse(move: "e8c8", for: .black, in: p4)
//        XCTAssertEqual(bLongCastle?.result, .castle(.bQ))
//    }
//    
//    @Test
//    func testPromotion() {
//        let p = Position(fen: "8/P7/8/8/8/8/8/8 w - - 0 1")!
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
