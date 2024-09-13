import XCTest
@testable import FischerCore

final class CastlingRightsTests: XCTestCase {
    func testStringValue() throws {
        XCTAssertEqual(CastlingRights.Right.whiteKingside.stringValue, "K")
        XCTAssertEqual(CastlingRights.Right.whiteQueenside.stringValue, "Q")
        XCTAssertEqual(CastlingRights.Right.blackKingside.stringValue, "k")
        XCTAssertEqual(CastlingRights.Right.blackQueenside.stringValue, "q")
    }
    
    func testColorValue() throws {
        XCTAssertEqual(CastlingRights.Right.whiteKingside.color, .white)
        XCTAssertEqual(CastlingRights.Right.whiteQueenside.color, .white)
        XCTAssertEqual(CastlingRights.Right.blackKingside.color, .black)
        XCTAssertEqual(CastlingRights.Right.blackQueenside.color, .black)
        
        var sut = CastlingRights.Right.whiteKingside
        sut.color = .black
        
        XCTAssertEqual(sut, .blackKingside)
    }
    
    func testSideValue() throws {
        XCTAssertEqual(CastlingRights.Right.whiteKingside.side, .kingside)
        XCTAssertEqual(CastlingRights.Right.whiteQueenside.side, .queenside)
        XCTAssertEqual(CastlingRights.Right.blackKingside.side, .kingside)
        XCTAssertEqual(CastlingRights.Right.blackQueenside.side, .queenside)
        
        var sut = CastlingRights.Right.whiteKingside
        sut.side = .queenside
        
        XCTAssertEqual(sut, .whiteQueenside)
    }
    
    func testStaticValues() throws {
        XCTAssertEqual( CastlingRights.white, [.whiteKingside, .whiteQueenside])
        XCTAssertEqual( CastlingRights.black, [.blackKingside, .blackQueenside])
        XCTAssertEqual( CastlingRights.kingside, [.whiteKingside, .blackKingside])
        XCTAssertEqual( CastlingRights.queenside, [.whiteQueenside, .blackQueenside])
    }
    
    func testDescription() throws {
        XCTAssertEqual(CastlingRights.Right.whiteKingside.description, "whiteKingside")
    }
    
    func testEmtySquares() throws {
        XCTAssertEqual(CastlingRights.Right.whiteKingside.emptySquares, Bitboard(squares: [.f1, .g1]))
        XCTAssertEqual(CastlingRights.Right.whiteQueenside.emptySquares, Bitboard(squares: [.b1, .c1, .d1]))
        XCTAssertEqual(CastlingRights.Right.blackKingside.emptySquares, Bitboard(squares: [.f8, .g8]))
        XCTAssertEqual(CastlingRights.Right.blackQueenside.emptySquares, Bitboard(squares: [.b8, .c8, .d8]))
    }
    
    func testSquare() throws {
        XCTAssertEqual(CastlingRights.Right.whiteKingside.castleSquare, .g1)
        XCTAssertEqual(CastlingRights.Right.whiteQueenside.castleSquare, .c1)
        XCTAssertEqual(CastlingRights.Right.blackKingside.castleSquare, .g8)
        XCTAssertEqual(CastlingRights.Right.blackQueenside.castleSquare, .c8)
    }
    
    func testInit() throws {
        XCTAssertEqual(CastlingRights.Right(color: .white, side: .kingside), .whiteKingside)
        XCTAssertEqual(CastlingRights.Right(color: .white, side: .queenside), .whiteQueenside)
        XCTAssertEqual(CastlingRights.Right(color: .black, side: .kingside), .blackKingside)
        XCTAssertEqual(CastlingRights.Right(color: .black, side: .queenside), .blackQueenside)
    }
    
    func testInitWithString() throws {
        XCTAssertEqual(CastlingRights.Right(string: "K"), .whiteKingside)
        XCTAssertEqual(CastlingRights.Right(string: "Q"), .whiteQueenside)
        XCTAssertEqual(CastlingRights.Right(string: "k"), .blackKingside)
        XCTAssertEqual(CastlingRights.Right(string: "q"), .blackQueenside)
        XCTAssertNil(CastlingRights.Right(string: "test"))
    }
    
    func testIterator() throws {
        var right = CastlingRights.white
        var iterator = right.makeIterator()
        XCTAssertNotNil(iterator.next())
        XCTAssertNotNil(iterator.next())
        XCTAssertNil(iterator.next())
    }
    
    func testCastlingDescription() throws {
        XCTAssertEqual(CastlingRights.white.description, "KQ")
        XCTAssertEqual(CastlingRights().description, "-")
    }
    
    func testCastlingRightsInitWithString() throws {
        XCTAssertNil(CastlingRights(string: ""))
        XCTAssertEqual(CastlingRights(string: "-"), CastlingRights())
        XCTAssertEqual(CastlingRights(string: "KQ"), CastlingRights.white)
        XCTAssertNil(CastlingRights(string: "test"))
    }
    
    func testCastlingRightsInitWithColor() throws {
        XCTAssertEqual(CastlingRights(color: .white), CastlingRights.white)
        XCTAssertEqual(CastlingRights(color: .black), CastlingRights.black)
    }
    
    func testCastlingRightsInitWithSide() throws {
        XCTAssertEqual(CastlingRights(side: .kingside), CastlingRights.kingside)
        XCTAssertEqual(CastlingRights(side: .queenside), CastlingRights.queenside)
    }
    
    func testInitWithSequence() throws {
        XCTAssertEqual(CastlingRights([.whiteKingside, .whiteQueenside]), CastlingRights.white)
        XCTAssertEqual(CastlingRights(Set([.blackKingside, .blackQueenside])), CastlingRights.black)
    }
    
    func testAlgebra() throws {
        XCTAssertTrue(CastlingRights().isEmpty)
        XCTAssertTrue(CastlingRights.white.contains(.whiteKingside))
        XCTAssertEqual(CastlingRights.white.union(CastlingRights.black), CastlingRights.all)
        XCTAssertEqual(CastlingRights.all.intersection(CastlingRights.black), CastlingRights.black)
        XCTAssertEqual(
            CastlingRights.white.symmetricDifference(CastlingRights(side:.kingside)),
            CastlingRights([CastlingRights.Right.whiteQueenside, .blackKingside])
        )
        var sut = CastlingRights.kingside
        sut.insert(.blackQueenside)
        sut.update(with: .whiteQueenside)
        XCTAssertEqual(
            sut,
            CastlingRights.all
        )
        sut.remove(.blackQueenside)
        sut.remove(.whiteQueenside)
        
        XCTAssertEqual(
            sut,
            CastlingRights.kingside
        )
        
        sut.formUnion(CastlingRights.queenside)
        XCTAssertEqual(
            sut,
            CastlingRights.all
        )
        
        sut.formIntersection(.kingside)
        
        XCTAssertEqual(
            sut,
            CastlingRights.kingside
        )
        
        sut.formSymmetricDifference(.white)
        
        XCTAssertEqual(
            sut,
            CastlingRights(string: "kQ")
        )
        
        sut.subtract(CastlingRights.white)
        
        XCTAssertTrue(sut.isSubset(of: CastlingRights.kingside))
        XCTAssertTrue(CastlingRights.kingside.isSuperset(of: sut))
        
        XCTAssertEqual(CastlingRights.white.subtracting(.kingside), CastlingRights(string: "Q"))
        XCTAssertTrue(CastlingRights.white.isDisjoint(with: CastlingRights.black))
    }
}
