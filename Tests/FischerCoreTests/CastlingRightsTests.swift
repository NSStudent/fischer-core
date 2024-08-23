import Testing
@testable import FischerCore

final class CastlingRightsTests {

    @Test("Castling Rights String Value")
    func testStringValue() throws {
        #expect(CastlingRights.Right.whiteKingside.stringValue == "K")
        #expect(CastlingRights.Right.whiteQueenside.stringValue == "Q")
        #expect(CastlingRights.Right.blackKingside.stringValue == "k")
        #expect(CastlingRights.Right.blackQueenside.stringValue == "q")
    }

    @Test("Castling Rights Color Value")
    func testColorValue() throws {
        #expect(CastlingRights.Right.whiteKingside.color == .white)
        #expect(CastlingRights.Right.whiteQueenside.color == .white)
        #expect(CastlingRights.Right.blackKingside.color == .black)
        #expect(CastlingRights.Right.blackQueenside.color == .black)

        var sut = CastlingRights.Right.whiteKingside
        sut.color = .black

        #expect(sut == .blackKingside)
    }

    @Test("Castling Rights Side Value")
    func testSideValue() throws {
        #expect(CastlingRights.Right.whiteKingside.side == .kingside)
        #expect(CastlingRights.Right.whiteQueenside.side == .queenside)
        #expect(CastlingRights.Right.blackKingside.side == .kingside)
        #expect(CastlingRights.Right.blackQueenside.side == .queenside)

        var sut = CastlingRights.Right.whiteKingside
        sut.side = .queenside

        #expect(sut == .whiteQueenside)
    }

    @Test("Castling Rights Static Values")
    func testStaticValues() throws {
        #expect(CastlingRights.white == [.whiteKingside, .whiteQueenside])
        #expect(CastlingRights.black == [.blackKingside, .blackQueenside])
        #expect(CastlingRights.kingside == [.whiteKingside, .blackKingside])
        #expect(CastlingRights.queenside == [.whiteQueenside, .blackQueenside])
    }

    @Test("Castling Rights Description")
    func testDescription() throws {
        #expect(CastlingRights.Right.whiteKingside.description == "whiteKingside")
    }

    @Test("Castling Rights Empty Squares")
    func testEmptySquares() throws {
        #expect(CastlingRights.Right.whiteKingside.emptySquares == Bitboard(squares: [.f1, .g1]))
        #expect(CastlingRights.Right.whiteQueenside.emptySquares == Bitboard(squares: [.b1, .c1, .d1]))
        #expect(CastlingRights.Right.blackKingside.emptySquares == Bitboard(squares: [.f8, .g8]))
        #expect(CastlingRights.Right.blackQueenside.emptySquares == Bitboard(squares: [.b8, .c8, .d8]))
    }

    @Test("Castling Rights Square")
    func testSquare() throws {
        #expect(CastlingRights.Right.whiteKingside.castleSquare == .g1)
        #expect(CastlingRights.Right.whiteQueenside.castleSquare == .c1)
        #expect(CastlingRights.Right.blackKingside.castleSquare == .g8)
        #expect(CastlingRights.Right.blackQueenside.castleSquare == .c8)
    }

    @Test("Castling Rights Initialization")
    func testInit() throws {
        #expect(CastlingRights.Right(color: .white, side: .kingside) == .whiteKingside)
        #expect(CastlingRights.Right(color: .white, side: .queenside) == .whiteQueenside)
        #expect(CastlingRights.Right(color: .black, side: .kingside) == .blackKingside)
        #expect(CastlingRights.Right(color: .black, side: .queenside) == .blackQueenside)
    }

    @Test("Castling Rights Initialization with String")
    func testInitWithString() throws {
        #expect(CastlingRights.Right(string: "K") == .whiteKingside)
        #expect(CastlingRights.Right(string: "Q") == .whiteQueenside)
        #expect(CastlingRights.Right(string: "k") == .blackKingside)
        #expect(CastlingRights.Right(string: "q") == .blackQueenside)
        #expect(CastlingRights.Right(string: "test") == nil)
    }

    @Test("Castling Rights Iterator")
    func testIterator() throws {
        let rights = CastlingRights.white
        var iterator = rights.makeIterator()
        #expect(iterator.next() != nil)
        #expect(iterator.next() != nil)
        #expect(iterator.next() == nil)
    }

    @Test("Castling Rights Description Formatting")
    func testCastlingDescription() throws {
        #expect(CastlingRights.white.description == "KQ")
        #expect(CastlingRights().description == "-")
    }

    @Test("Castling Rights Initialization with String")
    func testCastlingRightsInitWithString() throws {
        #expect(CastlingRights(string: "") == nil)
        #expect(CastlingRights(string: "-") == CastlingRights())
        #expect(CastlingRights(string: "KQ") == CastlingRights.white)
        #expect(CastlingRights(string: "test") == nil)
    }

    @Test("Castling Rights Initialization with Color")
    func testCastlingRightsInitWithColor() throws {
        #expect(CastlingRights(color: .white) == CastlingRights.white)
        #expect(CastlingRights(color: .black) == CastlingRights.black)
    }

    @Test("Castling Rights Initialization with Side")
    func testCastlingRightsInitWithSide() throws {
        #expect(CastlingRights(side: .kingside) == CastlingRights.kingside)
        #expect(CastlingRights(side: .queenside) == CastlingRights.queenside)
    }

    @Test("Castling Rights Initialization with Sequence")
    func testInitWithSequence() throws {
        #expect(CastlingRights([.whiteKingside, .whiteQueenside]) == CastlingRights.white)
        #expect(CastlingRights(Set([.blackKingside, .blackQueenside])) == CastlingRights.black)
    }

    @Test("Castling Rights Algebra")
    func testAlgebra() throws {
        #expect(CastlingRights().isEmpty)
        #expect(CastlingRights.white.contains(.whiteKingside))
        #expect(CastlingRights.white.union(CastlingRights.black) == CastlingRights.all)
        #expect(CastlingRights.all.intersection(CastlingRights.black) == CastlingRights.black)
        #expect(CastlingRights.white.subtracting(.kingside) == CastlingRights(string: "Q"))
        #expect(CastlingRights.white.isDisjoint(with: CastlingRights.black))
    }
}
