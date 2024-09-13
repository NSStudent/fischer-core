import XCTest
@testable import FischerCore

final class BoardTests: XCTestCase {
    func testBoardAscii() throws {
        let board = Board()
        XCTAssertEqual(
            board.ascii(),
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
    
    func testSpace() throws {
        var sut = Board()
        var iterator = sut.makeIterator()
        XCTAssertEqual(sut[.a1], Piece("R"))
        XCTAssertEqual(sut.space(at: .a1), Board.Space(piece: Piece("R"), square: .a1))
        XCTAssertEqual(sut.space(at: .h1), Board.Space(piece: Piece("R"), location: (file: .h, rank: .one)))
        XCTAssertEqual(sut.space(at: .a1), iterator.next())
        (1...62).forEach{_ in _ = iterator.next()}
        XCTAssertEqual(sut.space(at: .h8), iterator.next())
        XCTAssertNil(iterator.next())
        XCTAssertEqual(sut.underestimatedCount, 64)
        
        sut[(file: .a, rank: .one)] = Piece("Q")
        XCTAssertEqual(sut[(file: .a, rank: .one)], Piece("Q"))
        
        sut[(file: .a, rank: .one)] = Piece("R")
        
        XCTAssertEqual(sut[Piece(king: .white)], Bitboard(square: .e1))
        sut[Piece(king: .white)] = Bitboard(square: .e3)
        XCTAssertEqual(sut[Piece(king: .white)], Bitboard(square: .e3))
        sut[Piece(king: .white)] = Bitboard(square: .e1)
        XCTAssertEqual(sut.bitboard(for: Piece(queen: .white)), Bitboard(square: .d1))
        XCTAssertEqual(sut.squareForKing(for: .black), .e8)
        XCTAssertEqual(
            Board(fen: "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")!.pinned(for: .white),
            Bitboard(squares: [.f4, .g3])
        )
        
        XCTAssertEqual(
            Board(fen: "rnb1kbnr/pppp1ppp/4p3/8/6Pq/5P2/PPPPP2P/RNBQKBNR")!.attackersToKing(for: .white),
            Bitboard(square: .h4)
        )
        sut[.e1] = nil
        XCTAssertEqual(
            sut.attackersToKing(for: .white),
            Bitboard()
        )
        XCTAssertEqual(
            sut.pinned(for: .white),
            Bitboard()
        )
        sut[.e1] = Piece(king: .white)
        
        XCTAssertEqual(Board(fen: "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")!.fen(), "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")
        XCTAssertEqual(Board(fen: "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")!.description, "rnbqk1n1/pppp1pp1/5r2/4p2p/4PP1b/PP4P1/2PP1K1P/RNBQ1BNR")
        
        XCTAssertEqual(Board(fen: "k7/8/8/8/8/8/8/K7")!.whitePieces, [Piece(king: .white)])
        XCTAssertEqual(Board(fen: "k7/8/8/8/8/8/8/K7")!.blackPieces, [Piece(king: .black)])
        XCTAssertEqual(Board(fen: "kPPPPPP1/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/KPPPPPPP")!.emptySpaces, Bitboard(square: .h8))
        XCTAssertEqual(Board(fen: "8/8/8/8/8/8/8/K7")!.occupiedSpaces, Bitboard(square: .a1))
        XCTAssertEqual(Board(fen: "kPPPPPP1/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/PPPPPPPP/KPPPPPPP")!.count(of: Piece(pawn: .white)), 61)
        
    }
}
