import Testing
@testable import FischerCore

final class SquareTests {

    @Test("Square ID Value")
    func testIdValue() throws {
        #expect(Square.a1.id == 0)
    }

    @Test("Square Mutations")
    func testSquareMutations() throws {
        var mutableSquare = Square.a1
        mutableSquare.file = .b
        #expect(mutableSquare == .b1)
        mutableSquare.rank = 2
        #expect(mutableSquare == .b2)
        #expect(mutableSquare.location.file == .b)
        mutableSquare.location = (file: .e, rank: 4)
        #expect(mutableSquare == .e4)
    }

    @Test("Square Initializations")
    func testInits() throws {
        #expect(Square("e") == nil)
        #expect(Square("e4") == .e4)
        #expect(Square("i4") == nil)
        #expect(Square("ee") == nil)
    }

    @Test("Square Grid Collection")
    func testGrid() throws {
        #expect(Square.gridCollection.first == .a8)
    }

    @Test("Square Attacks")
    func testAttacks() throws {
        #expect(Square.e4.attacks(for: Piece(king: .white)) == Bitboard(squares: [.d5, .d4, .d3, .e5, .e3, .f5, .f4, .f3]))
        #expect(Square.e4.attacks(for: Piece(knight: .white)) == Bitboard(squares: [.d6, .f6, .g5, .g3, .f2, .d2, .c3, .c5]))
        #expect(Square.e4.attacks(for: Piece(pawn: .white)) == Bitboard(squares: [.d5, .f5]))
        #expect(Square.e4.attacks(for: Piece(pawn: .black)) == Bitboard(squares: [.d3, .f3]))
        #expect(Square.e4.attacks(for: Piece(rook: .white)) == Bitboard(file: .e) ^ Bitboard(rank: .four))
    }

    @Test("Square Between")
    func testBetween() throws {
        #expect(Square.e1.between(.e3) == Bitboard(square: .e2))
    }

    @Test("Square Color")
    func testColor() throws {
        #expect(Square.e1.color == .dark)
        #expect(Square.e2.color == .light)
    }
}
