import XCTest
@testable import FischerCore

final class SquareTests: XCTestCase {
    
    func testIdValue() throws {
        XCTAssertEqual(Square.a1.id, 0)
    }

    func testSquareMutations() throws {
        var mutableSquare = Square.a1
        mutableSquare.file = .b
        XCTAssertEqual(mutableSquare, .b1)
        mutableSquare.rank = 2
        XCTAssertEqual(mutableSquare, .b2)
        XCTAssertEqual(mutableSquare.location.file, .b)
        mutableSquare.location = (file: .e, rank: 4)
        XCTAssertEqual(mutableSquare, .e4)
    }

    func testInits() throws {
        XCTAssertEqual(Square("e"), nil)
        XCTAssertEqual(Square("e4"), .e4)
        XCTAssertEqual(Square("i4"), nil)
        XCTAssertEqual(Square("ee"), nil)
    }

    func testGrid() throws {
        XCTAssertEqual( Square.gridCollection.first, .a8)
    }

    func testAttacks() throws {
        XCTAssertEqual(Square.e4.attacks(for: Piece(king: .white)),  Bitboard(squares: [.d5, .d4, .d3, .e5, .e3, .f5, .f4, .f3]))
        XCTAssertEqual(Square.e4.attacks(for: Piece(knight: .white)), Bitboard(squares: [.d6, .f6, .g5, .g3, .f2, .d2, .c3, .c5]))
        XCTAssertEqual(Square.e4.attacks(for: Piece(pawn: .white)), Bitboard(squares: [.d5, .f5]))
        XCTAssertEqual(Square.e4.attacks(for: Piece(pawn: .black)), Bitboard(squares: [.d3, .f3]))
        XCTAssertEqual(Square.e4.attacks(for: Piece(rook: .white)), Bitboard(file: .e) ^ Bitboard(rank: .four))
    }

    func testBetween() throws {
        XCTAssertEqual(Square.e1.between(.e3), Bitboard(square: .e2))
    }

    func testColor() throws {
        XCTAssertEqual(Square.e1.color, .dark)
        XCTAssertEqual(Square.e2.color, .light)
    }

}
