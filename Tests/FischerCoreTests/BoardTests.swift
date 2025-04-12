import Testing
@testable import FischerCore

final class BoardTests {

    @Test("Board ASCII Representation")
    func testBoardAscii() throws {
        let board = Board()
        #expect(
            board.ascii() ==
            """
              +-----------------+
            8 | ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ |
            7 | ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙ |
            6 | . . . . . . . . |
            5 | . . . . . . . . |
            4 | . . . . . . . . |
            3 | . . . . . . . . |
            2 | ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟ |
            1 | ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜ |
              +-----------------+
                a b c d e f g h
            """
        )
    }

    @Test("Board Space Access")
    func testSpace() throws {
        var sut = Board()
        var iterator = sut.makeIterator()
        #expect(sut[.a1] == Piece("R"))
        #expect(sut.space(at: .a1) == Board.Space(piece: Piece("R"), square: .a1))
        #expect(sut.space(at: .h1) == Board.Space(piece: Piece("R"), location: (file: .h, rank: .one)))
        #expect(sut.space(at: .a1) == iterator.next())
        (1...62).forEach{_ in _ = iterator.next()}
        #expect(sut.space(at: .h8) == iterator.next())
        #expect(iterator.next() == nil)
        #expect(sut.underestimatedCount == 64)

        sut[(file: .a, rank: .one)] = Piece("Q")
        #expect(sut[(file: .a, rank: .one)] == Piece("Q"))

        sut[(file: .a, rank: .one)] = Piece("R")

        #expect(sut[Piece(king: .white)] == Bitboard(square: .e1))
        sut[Piece(king: .white)] = Bitboard(square: .e3)
        #expect(sut[Piece(king: .white)] == Bitboard(square: .e3))
        sut[Piece(king: .white)] = Bitboard(square: .e1)
        #expect(sut.bitboard(for: Piece(queen: .white)) == Bitboard(square: .d1))
        #expect(sut.squareForKing(for: .black) == .e8)
        #expect(
            Board(fen: "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")!.pinned(for: .white) ==
            Bitboard(squares: [.f4, .g3])
        )
        
        #expect(
            Board(fen: "rnb1kbnr/pppp1ppp/4p3/8/6Pq/5P2/PPPPP2P/RNBQKBNR")!.attackersToKing(for: .white) ==
            Bitboard(square: .h4)
        )
        sut[.e1] = nil
        #expect(
            sut.attackersToKing(for: .white) ==
            Bitboard()
        )
        #expect(
            sut.pinned(for: .white) ==
            Bitboard()
        )
        sut[.e1] = Piece(king: .white)
        
        #expect(Board(fen: "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")!.fen() == "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")
        #expect(Board(fen: "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")!.description == "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")
        
        #expect(Board(fen: "k7/8/8/8/8/8/8/K7")!.whitePieces == [Piece(king: .white)])
        #expect(Board(fen: "k7/8/8/8/8/8/8/K7")!.blackPieces == [Piece(king: .black)])
        #expect(Board(fen: "kPPPPPP1/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/KPPPPPPP")!.emptySpaces == Bitboard(square: .h8))
        #expect(Board(fen: "8/8/8/8/8/8/8/K7")!.occupiedSpaces == Bitboard(square: .a1))
        #expect(Board(fen: "kPPPPPP1/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/KPPPPPPP")!.count(of: Piece(pawn: .white)) == 61)
    }

    @Test("Board FEN Parsing")
    func testFen() throws {
        #expect(Board(fen: "1") == nil)
        #expect(Board(fen: "g7/8/8/8/8/8/8/K7") == nil)
        #expect(Board(fen: "PPPPPPPPPP/8/8/8/8/8/8/K7") == nil)
    }
}
