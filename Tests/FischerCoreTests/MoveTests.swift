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

}
