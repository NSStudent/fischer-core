import Testing
@testable import FischerCore

final class PieceTests {

    @Test("Piece Kind Name")
    func testPieceKindName() throws {
        #expect(Piece.Kind.pawn.name == "pawn")
        #expect(Piece.Kind.knight.name == "knight")
        #expect(Piece.Kind.bishop.name == "bishop")
        #expect(Piece.Kind.queen.name == "queen")
        #expect(Piece.Kind.rook.name == "rook")
        #expect(Piece.Kind.king.name == "king")
    }

    @Test("Piece FEN Initialization")
    func testFENInit() throws {
        #expect(Piece.init("P") == Piece(pawn: .white))
        #expect(Piece.init("p") == Piece(pawn: .black))
        #expect(Piece.init("N") == Piece(knight: .white))
        #expect(Piece.init("n") == Piece(knight: .black))
        #expect(Piece.init("B") == Piece(bishop: .white))
        #expect(Piece.init("b") == Piece(bishop: .black))
        #expect(Piece.init("Q") == Piece(queen: .white))
        #expect(Piece.init("q") == Piece(queen: .black))
        #expect(Piece.init("R") == Piece(rook: .white))
        #expect(Piece.init("r") == Piece(rook: .black))
        #expect(Piece.init("K") == Piece(king: .white))
        #expect(Piece.init("k") == Piece(king: .black))
        #expect(Piece.init("invalid") == nil)
    }

    @Test("Piece FEN Name")
    func testFENName() throws {
        #expect(Piece(pawn: .white).fenName == "P")
        #expect(Piece(pawn: .black).fenName == "p")
        #expect(Piece(knight: .white).fenName == "N")
        #expect(Piece(knight: .black).fenName == "n")
        #expect(Piece(bishop: .white).fenName == "B")
        #expect(Piece(bishop: .black).fenName == "b")
        #expect(Piece(queen: .white).fenName == "Q")
        #expect(Piece(queen: .black).fenName == "q")
        #expect(Piece(rook: .white).fenName == "R")
        #expect(Piece(rook: .black).fenName == "r")
        #expect(Piece(king: .white).fenName == "K")
        #expect(Piece(king: .black).fenName == "k")
    }

    @Test("Piece Special Character")
    func testSpecialCharacter() throws {
        #expect(Piece(pawn: .white).specialCharacter == "♟")
        #expect(Piece(pawn: .black).specialCharacter == "♙")
        #expect(Piece(knight: .white).specialCharacter == "♞")
        #expect(Piece(knight: .black).specialCharacter == "♘")
        #expect(Piece(bishop: .white).specialCharacter == "♝")
        #expect(Piece(bishop: .black).specialCharacter == "♗")
        #expect(Piece(queen: .white).specialCharacter == "♛")
        #expect(Piece(queen: .black).specialCharacter == "♕")
        #expect(Piece(rook: .white).specialCharacter == "♜")
        #expect(Piece(rook: .black).specialCharacter == "♖")
        #expect(Piece(king: .white).specialCharacter == "♚")
        #expect(Piece(king: .black).specialCharacter == "♔")
    }

    @Test("Piece Initialization with Int Value")
    func testInitWithIntValue() throws {
        #expect(Piece.init(value: 1) == Piece(pawn: .black))
        #expect(Piece.init(value: 0) == Piece(pawn: .white))
        #expect(Piece.init(value: 42) == nil)
    }

    @Test("Piece Can Promote")
    func testCanPromote() throws {
        #expect(!Piece(pawn: .black).kind.canPromote())
        #expect(!Piece(king: .black).kind.canPromote())
        #expect(Piece(queen: .black).kind.canPromote())
    }

    @Test("Piece Boolean Functions")
    func testBooleanFunctions() throws {
        let pawn = Piece(pawn: .white)
        #expect(pawn.kind.isPawn)
        #expect(!pawn.kind.isKnight)
        #expect(!pawn.kind.isBishop)
        #expect(!pawn.kind.isRook)
        #expect(!pawn.kind.isQueen)
        #expect(!pawn.kind.isKing)
    }

    @Test("Piece All Bitboard Logic")
    func testAllBitboardLogic() {
        let blackPawn = Piece(pawn: .black)
        #expect(blackPawn.bitValue == 1)
    }

    @Test("Piece Array Collections")
    func testArrayPieces() {
        #expect(Piece.all.count == 12)
        #expect(Piece.whitePieces.count == 6)
        #expect(Piece.blackPieces.count == 6)
        #expect(Piece.whiteNonQueens.count == 5)
        #expect(Piece.blackNonQueens.count == 5)
        #expect(Piece.nonQueens(for: .white).count == Piece.whiteNonQueens.count)
        #expect(Piece.nonQueens(for: .black).count == Piece.blackNonQueens.count)
        #expect(Piece.whiteHashes == [0, 2, 4, 6, 8, 10])
        #expect(Piece.blackHashes == [1, 3, 5, 7, 9, 11])
        #expect(Piece.whiteHashes == Piece.hashes(for: .white))
        #expect(Piece.blackHashes == Piece.hashes(for: .black))
    }
}
