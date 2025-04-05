import Testing
@testable import FischerCore

final class MoveTests {

    let e2e4Move = Move(start: .e2, end: .e4)
    let a1h1Move = Move(start: .a1, end: .h1)
    let diagonalMove = (file: .a, rank: .one) >>> (file: .h, rank: .eight)
    let knightMove = Move(start: (file: .f, rank: .three), end: (file: .d, rank: .four))

    @Test("Move Description")
    func testDescription() throws {
        #expect(e2e4Move.description == "e2 >>> e4")
    }

    @Test("Move Changes")
    func testChanges() throws {
        #expect(e2e4Move.rankChange == 2)
        #expect(e2e4Move.fileChange == 0)
        #expect(a1h1Move.rankChange == 0)
        #expect(a1h1Move.fileChange == 7)
        #expect(e2e4Move.isChange)
    }

    @Test("Move Orientation Booleans")
    func testOrientationBooleans() throws {
        #expect(e2e4Move.isVertical)
        #expect(e2e4Move.isAxial)
        #expect(!e2e4Move.isHorizontal)
        #expect(!e2e4Move.isDiagonal)
        #expect(e2e4Move.isUpward)
        #expect(!e2e4Move.isDownward)

        #expect(a1h1Move.isHorizontal)
        #expect(!a1h1Move.isVertical)
        #expect(!a1h1Move.isDiagonal)
        #expect(a1h1Move.isRightward)
        #expect(!a1h1Move.isLeftward)

        #expect(!e2e4Move.isKnightJump)
        #expect(knightMove.isKnightJump)

        #expect(a1h1Move.fileDirection == .right)
        #expect(a1h1Move.reversed().fileDirection == .left)
        #expect(e2e4Move.fileDirection == .none)

        #expect(e2e4Move.rankDirection == .up)
        #expect(e2e4Move.reversed().rankDirection == .down)
        #expect(a1h1Move.rankDirection == .none)
    }

    @Test("Castling Moves")
    func testCastles() throws {
        #expect(Move(castle: .white, direction: .left) == Move(start: .e1, end: .c1))
        #expect(Move(castle: .white, direction: .right) == Move(start: .e1, end: .g1))
        #expect(Move(castle: .black, direction: .left) == Move(start: .e8, end: .c8))
        #expect(Move(castle: .black, direction: .right) == Move(start: .e8, end: .g8))

        let whiteLeftCastleSquares = Move(castle: .white, direction: .left).castleSquares()
        #expect(whiteLeftCastleSquares.old == .a1)
        #expect(whiteLeftCastleSquares.new == .d1)
        let whiteRightCastleSquares = Move(castle: .white, direction: .right).castleSquares()
        #expect(whiteRightCastleSquares.old == .h1)
        #expect(whiteRightCastleSquares.new == .f1)

        #expect(!e2e4Move.isCastle())
        #expect(!e2e4Move.isLongCastle())
        #expect(!e2e4Move.isShortCastle())
        #expect(Move(castle: .white, direction: .left).isCastle())
        #expect(Move(castle: .white, direction: .left).isLongCastle())
        #expect(!Move(castle: .white, direction: .right).isLongCastle())
        #expect(Move(castle: .white, direction: .left).isLongCastle(for: .white))
        #expect(!Move(castle: .white, direction: .left).isLongCastle(for: .black))
        #expect(Move(castle: .white, direction: .left).isCastle(for: .white))
        #expect(!Move(castle: .white, direction: .left).isCastle(for: .black))
        #expect(!Move(start: .e1, end: .h1).isCastle(for: .white))
        #expect(Move(castle: .white, direction: .right).isShortCastle())
        #expect(Move(castle: .white, direction: .right).isShortCastle(for: .white))
        #expect(!Move(castle: .white, direction: .right).isShortCastle(for: .black))
    }

    @Test("Move Rotation")
    func testRotation() throws {
        let rotated = e2e4Move.rotated()
        #expect(rotated == Move(start: .d7, end: .d5))
    }

    @Test("Move Sequences")
    func testSequences() {
        let sequence = [Square.e4, .d4]
        #expect(sequence.moves(from: .e2) == [.e2 >>> .e4, .e2 >>> .d4])
        #expect(sequence.moves(to: .e5) == [.e4 >>> .e5, .d4 >>> .e5])
    }

    @Test("Init with SANMove and Board")
    func initWithSanMoveAndBoard() async throws {
        let board = Board()
        let sanMove = try SanMoveParser().parse("e4")
        let move = try Move(board: board, sanMove: sanMove, turn: .white)
        #expect(move.start == .e2)
        #expect(move.end == .e4)
        
        #expect(throws: FischerCoreError.illegalMove) {
            let sanIllegalMove = try SanMoveParser().parse("e6")
            let _ = try Move(board: board, sanMove: sanIllegalMove, turn: .white)
        }
        
        guard let board2 = Board(fen: "rnbqkbnr/ppp2ppp/8/3pp3/3P4/5N2/PPP1PPPP/RNBQKB1R") else {
            Issue.record("board fen error")
            return
        }
        let sanMove2 = try SanMoveParser().parse("Nfd2")
        let move2 = try Move(board: board2, sanMove: sanMove2, turn: .white)
        #expect(move2.start == .f3)
        #expect(move2.end == .d2)
        
        guard let board3 = Board(fen: "7k/8/2N5/8/5N2/8/3KN3/8") else {
            Issue.record("board fen error")
            return
        }
        
        let sanMove3 = try SanMoveParser().parse("N2d4")
        let move3 = try Move(board: board3, sanMove: sanMove3, turn: .white)
        #expect(move3.start == .e2)
        #expect(move3.end == .d4)
        
        
        #expect(throws: FischerCoreError.illegalMove) {
            let sanIllegalMove2 = try SanMoveParser().parse("N3d4")
            let _ = try Move(board: board, sanMove: sanIllegalMove2, turn: .white)
        }
        
        let sanMove5 = try SanMoveParser().parse("O-O")
        let move5 = try Move(board: board, sanMove: sanMove5, turn: .white)
        #expect(move5.start == .e1)
        #expect(move5.end == .g1)
        
        let sanMove6 = try SanMoveParser().parse("O-O-O")
        let move6 = try Move(board: board, sanMove: sanMove6, turn: .white)
        #expect(move6.start == .e1)
        #expect(move6.end == .c1)
        
        
        let sanMove7 = try SanMoveParser().parse("O-O")
        let move7 = try Move(board: board, sanMove: sanMove7, turn: .black)
        #expect(move7.start == .e8)
        #expect(move7.end == .g8)
        
        let sanMove8 = try SanMoveParser().parse("O-O-O")
        let move8 = try Move(board: board, sanMove: sanMove8, turn: .black)
        #expect(move8.start == .e8)
        #expect(move8.end == .c8)
        
        let sanMove9 = try SanMoveParser().parse("Ne2d4")
        let move9 = try Move(board: board3, sanMove: sanMove9, turn: .white)
        #expect(move9.start == .e2)
        #expect(move9.end == .d4)
    }
}
