import XCTest
@testable import FischerCore

final class PieceTests: XCTestCase {
    
    func testPieceKindName() throws {
        XCTAssertEqual(Piece.Kind.pawn.name, "pawn")
        XCTAssertEqual(Piece.Kind.knight.name, "knight")
        XCTAssertEqual(Piece.Kind.bishop.name, "bishop")
        XCTAssertEqual(Piece.Kind.queen.name, "queen")
        XCTAssertEqual(Piece.Kind.rook.name, "rook")
        XCTAssertEqual(Piece.Kind.king.name, "king")
    }
    
    func testFENInit() throws {
        XCTAssertEqual(Piece.init("P"), Piece(pawn: .white))
        XCTAssertEqual(Piece.init("p"), Piece(pawn: .black))
        XCTAssertEqual(Piece.init("N"), Piece(knight: .white))
        XCTAssertEqual(Piece.init("n"), Piece(knight: .black))
        XCTAssertEqual(Piece.init("B"), Piece(bishop: .white))
        XCTAssertEqual(Piece.init("b"), Piece(bishop: .black))
        XCTAssertEqual(Piece.init("Q"), Piece(queen: .white))
        XCTAssertEqual(Piece.init("q"), Piece(queen: .black))
        XCTAssertEqual(Piece.init("R"), Piece(rook: .white))
        XCTAssertEqual(Piece.init("r"), Piece(rook: .black))
        XCTAssertEqual(Piece.init("K"), Piece(king: .white))
        XCTAssertEqual(Piece.init("k"), Piece(king: .black))
    }
}
