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
    
    func testFENName() throws {
        XCTAssertEqual(Piece(pawn: .white).fenName, "P")
        XCTAssertEqual(Piece(pawn: .black).fenName, "p")
        XCTAssertEqual(Piece(knight: .white).fenName, "N")
        XCTAssertEqual(Piece(knight: .black).fenName, "n")
        XCTAssertEqual(Piece(bishop: .white).fenName, "B")
        XCTAssertEqual(Piece(bishop: .black).fenName, "b")
        XCTAssertEqual(Piece(queen: .white).fenName, "Q")
        XCTAssertEqual(Piece(queen: .black).fenName, "q")
        XCTAssertEqual(Piece(rook: .white).fenName, "R")
        XCTAssertEqual(Piece(rook: .black).fenName, "r")
        XCTAssertEqual(Piece(king: .white).fenName, "K")
        XCTAssertEqual(Piece(king: .black).fenName, "k")
    }
    
    func testSpecialCharacter() throws {
        XCTAssertEqual(Piece(pawn: .white).specialCharacter, "♟")
        XCTAssertEqual(Piece(pawn: .black).specialCharacter, "♙")
        XCTAssertEqual(Piece(knight: .white).specialCharacter, "♞")
        XCTAssertEqual(Piece(knight: .black).specialCharacter, "♘")
        XCTAssertEqual(Piece(bishop: .white).specialCharacter, "♝")
        XCTAssertEqual(Piece(bishop: .black).specialCharacter, "♗")
        XCTAssertEqual(Piece(queen: .white).specialCharacter, "♛")
        XCTAssertEqual(Piece(queen: .black).specialCharacter, "♕")
        XCTAssertEqual(Piece(rook: .white).specialCharacter, "♜")
        XCTAssertEqual(Piece(rook: .black).specialCharacter, "♖")
        XCTAssertEqual(Piece(king: .white).specialCharacter, "♚")
        XCTAssertEqual(Piece(king: .black).specialCharacter, "♔")
    }
    
    func testInitWithIntValue() throws {
        XCTAssertEqual(Piece.init(value: 1), Piece(pawn: .black))
        XCTAssertEqual(Piece.init(value: 0), Piece(pawn: .white))
    }
    
    func testCanPromote() throws {
        XCTAssertFalse(Piece(pawn: .black).kind.canPromote())
        XCTAssertFalse(Piece(king: .black).kind.canPromote())
        XCTAssertTrue(Piece(queen: .black).kind.canPromote())
    }
    
    func testBooleanFunctions() throws {
        let pawn = Piece(pawn: .white)
        XCTAssertTrue(pawn.kind.isPawn)
        XCTAssertFalse(pawn.kind.isKnight)
        XCTAssertFalse(pawn.kind.isBishop)
        XCTAssertFalse(pawn.kind.isRook)
        XCTAssertFalse(pawn.kind.isQueen)
        XCTAssertFalse(pawn.kind.isKing)
    }
    
    func testAllBitboardLogic() {
        let blackPawn = Piece(pawn: .black)
        XCTAssertEqual(blackPawn.bitValue, 1)
    }
    
    func testArrayPieces() {
        XCTAssertEqual(Piece.all.count, 12)
        XCTAssertEqual(Piece.whitePieces.count, 6)
        XCTAssertEqual(Piece.blackPieces.count, 6)
        XCTAssertEqual(Piece.whiteNonQueens.count, 5)
        XCTAssertEqual(Piece.blackNonQueens.count, 5)
        XCTAssertEqual(Piece.nonQueens(for: .white).count, Piece.whiteNonQueens.count)
        XCTAssertEqual(Piece.nonQueens(for: .black).count, Piece.blackNonQueens.count)
        XCTAssertEqual(Piece.whiteHashes, [0, 2, 4, 6, 8, 10])
        XCTAssertEqual(Piece.blackHashes, [1, 3, 5, 7, 9, 11])
        
        XCTAssertEqual(Piece.whiteHashes, Piece.hashes(for: .white))
        XCTAssertEqual(Piece.blackHashes, Piece.hashes(for: .black))
    }
}
