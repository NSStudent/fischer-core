import XCTest
@testable import FischerCore

final class MoveTests: XCTestCase {
    let e2e4Move = Move(start: .e2, end: .e4)
    let a1h1Move = Move(start: .a1, end: .h1)
    let diagonalMove = (file: .a, rank: .one) >>> (file: .h, rank: .eight)
    let knightMove = Move(start: (file: .f, rank: .three), end: (file: .d, rank: .four))
    func testDescription() throws {
        XCTAssertEqual(e2e4Move.description, "e2 >>> e4")
    }

    func testChanges() throws {
        XCTAssertEqual(e2e4Move.rankChange, 2)
        XCTAssertEqual(e2e4Move.fileChange, 0)
        XCTAssertEqual(a1h1Move.rankChange, 0)
        XCTAssertEqual(a1h1Move.fileChange, 7)
        XCTAssertTrue(e2e4Move.isChange)
    }

    func testOrientationBooleans() throws {
        XCTAssertTrue(e2e4Move.isVertical)
        XCTAssertTrue(e2e4Move.isAxial)
        XCTAssertFalse(e2e4Move.isHorizontal)
        XCTAssertFalse(e2e4Move.isDiagonal)
        XCTAssertTrue(e2e4Move.isUpward)
        XCTAssertFalse(e2e4Move.isDownward)

        XCTAssertTrue(a1h1Move.isHorizontal)
        XCTAssertFalse(a1h1Move.isVertical)
        XCTAssertFalse(a1h1Move.isDiagonal)
        XCTAssertTrue(a1h1Move.isRightward)
        XCTAssertFalse(a1h1Move.isLeftward)

        XCTAssertFalse(e2e4Move.isKnightJump)
        XCTAssertTrue(knightMove.isKnightJump)

        XCTAssertEqual(a1h1Move.fileDirection, .right)
        XCTAssertEqual(a1h1Move.reversed().fileDirection, .left)
        XCTAssertEqual(e2e4Move.fileDirection, .none)

        XCTAssertEqual(e2e4Move.rankDirection, .up)
        XCTAssertEqual(e2e4Move.reversed().rankDirection, .down)
        XCTAssertEqual(a1h1Move.rankDirection, .none)
    }

    func testCastles() throws {
        XCTAssertEqual(Move(castle: .white, direction: .left), Move(start: .e1, end: .c1))
        XCTAssertEqual(Move(castle: .white, direction: .right), Move(start: .e1, end: .g1))
        XCTAssertEqual(Move(castle: .black, direction: .left), Move(start: .e8, end: .c8))
        XCTAssertEqual(Move(castle: .black, direction: .right), Move(start: .e8, end: .g8))


        let whiteLeftCastleSquares = Move(castle: .white, direction: .left).castleSquares()
        XCTAssertEqual(whiteLeftCastleSquares.old, .a1)
        XCTAssertEqual(whiteLeftCastleSquares.new, .d1)
        let whiteRightCastleSquares = Move(castle: .white, direction: .right).castleSquares()
        XCTAssertEqual(whiteRightCastleSquares.old, .h1)
        XCTAssertEqual(whiteRightCastleSquares.new, .f1)

        XCTAssertFalse(e2e4Move.isCastle())
        XCTAssertFalse(e2e4Move.isLongCastle())
        XCTAssertFalse(e2e4Move.isShortCastle())
        XCTAssertTrue(Move(castle: .white, direction: .left).isCastle())
        XCTAssertTrue(Move(castle: .white, direction: .left).isLongCastle())
        XCTAssertFalse(Move(castle: .white, direction: .right).isLongCastle())
        XCTAssertTrue(Move(castle: .white, direction: .left).isLongCastle(for: .white))
        XCTAssertFalse(Move(castle: .white, direction: .left).isLongCastle(for: .black))
        XCTAssertTrue(Move(castle: .white, direction: .left).isCastle(for: .white))
        XCTAssertFalse(Move(castle: .white, direction: .left).isCastle(for: .black))
        XCTAssertFalse(Move(start: .e1, end: .h1).isCastle(for: .white))
        XCTAssertTrue(Move(castle: .white, direction: .right).isShortCastle())
        XCTAssertTrue(Move(castle: .white, direction: .right).isShortCastle(for: .white))
        XCTAssertFalse(Move(castle: .white, direction: .right).isShortCastle(for: .black))

    }

    func testRotation() throws {
        let rotated = e2e4Move.rotated()
        XCTAssertEqual(rotated, Move(start: .d7, end: .d5))
    }

    func testSequences() {
        let sequence = [Square.e4, .d4]
        XCTAssertEqual(sequence.moves(from: .e2), [.e2 >>> .e4, .e2 >>> .d4])
        XCTAssertEqual(sequence.moves(to: .e5), [.e4 >>> .e5, .d4 >>> .e5])
    }

}
