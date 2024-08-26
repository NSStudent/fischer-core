import XCTest
@testable import FischerCore

final class BitboardTests: XCTestCase {
    
    let multipleSquareBitboard = Bitboard(squares: [.b1, .h1])
    let e4Bitboard = Bitboard(location:(file: .e, rank: .four))
    
    func testBasicInit() {
        XCTAssertEqual(Bitboard(), Bitboard(rawValue: 0))
    }
    
    func testOperators() throws {
        let bitboard = Bitboard(square: .e4)
        var mBitboard = bitboard
        XCTAssertEqual(bitboard << 1, Bitboard(square: .f4))
        XCTAssertEqual(bitboard >> 1, Bitboard(square: .d4))
        mBitboard <<= 1
        XCTAssertEqual(mBitboard, Bitboard(square: .f4))
        mBitboard >>= 1
        XCTAssertEqual(mBitboard, Bitboard(square: .e4))
        
        XCTAssertEqual(Bitboard(file: .a) & Bitboard(rank: 1), Bitboard(square: .a1))
        XCTAssertEqual(
            Bitboard(file: .a) ^ Bitboard(rank: .one),
            (Bitboard(file: .a) | Bitboard(rank: .one)) & (~Bitboard(square: .a1)))
    }
    
    func testComparableOperators() throws {
        let a1Bitboard = Bitboard(square: .a1)
        let h8Bitboard = Bitboard(square: .h8)
        XCTAssertTrue(a1Bitboard < h8Bitboard)
        XCTAssertTrue(h8Bitboard > a1Bitboard)
    }
    
    func testLSBIndex() throws {
        XCTAssertEqual(multipleSquareBitboard.lsbIndex, 1)
        XCTAssertEqual(multipleSquareBitboard.lsbSquare, .b1)
    }
    
    func testMSBIndex() throws {
        XCTAssertNil(Bitboard().msbIndex)
        XCTAssertEqual(multipleSquareBitboard.msbIndex, 7)
        XCTAssertEqual(multipleSquareBitboard.msbSquare, .h1)
    }
    
    func testPopLSBBitboard() throws {
        var popLSBBitboard = multipleSquareBitboard
        let popedLSB = popLSBBitboard.popLSB()
        XCTAssertEqual(popLSBBitboard, Bitboard(square: .h1))
        XCTAssertEqual(popedLSB, Bitboard(square: .b1))
    }
    
    func testPopMSBBitboard() throws {
        var popMSBBitboard = multipleSquareBitboard
        let popedMSB = popMSBBitboard.popMSB()
        XCTAssertEqual(popMSBBitboard, Bitboard(square: .b1))
        XCTAssertEqual(popedMSB, Bitboard(square: .h1))
    }
    
    func testPopLSBIndex() throws {
        var popLSBBitboard = multipleSquareBitboard
        let popedLSBIndex = popLSBBitboard.popLSBIndex()
        XCTAssertEqual(popLSBBitboard, Bitboard(square: .h1))
        XCTAssertEqual(popedLSBIndex, 1)
    }
    
    func testPopMSBIndex() throws {
        var popMSBBitboard = multipleSquareBitboard
        let popedMSBIndex = popMSBBitboard.popMSBIndex()
        XCTAssertEqual(popMSBBitboard, Bitboard(square: .b1))
        XCTAssertEqual(popedMSBIndex, 7)
    }
    
    func testPopLSBSquare() throws {
        var popLSBBitboard = multipleSquareBitboard
        let popedLSBSquare = popLSBBitboard.popLSBSquare()
        XCTAssertEqual(popLSBBitboard, Bitboard(square: .h1))
        XCTAssertEqual(popedLSBSquare, .b1)
    }
    
    func testPopMSBSquare() throws {
        var popMSBBitboard = multipleSquareBitboard
        let popedMSBSquare = popMSBBitboard.popMSBSquare()
        XCTAssertEqual(popMSBBitboard, Bitboard(square: .b1))
        XCTAssertEqual(popedMSBSquare, .h1)
    }
    
    func testIsEmpty() throws {
        XCTAssertTrue(Bitboard().isEmpty)
        XCTAssertFalse(multipleSquareBitboard.isEmpty)
    }
    
    func testHasMoreThanOne() throws {
        XCTAssertFalse(Bitboard().hasMoreThanOne)
        XCTAssertTrue(multipleSquareBitboard.hasMoreThanOne)
    }
    
    func testCount() throws {
        XCTAssertEqual(multipleSquareBitboard.count, 2)
        XCTAssertEqual(Bitboard(file: .a).count, 8)
    }
    
    func testShift() throws {
        XCTAssertEqual(e4Bitboard.shifted(toward: .north), Bitboard(square: .e5))
        XCTAssertEqual(e4Bitboard.shifted(toward: .south), Bitboard(square: .e3))
        XCTAssertEqual(e4Bitboard.shifted(toward: .east), Bitboard(square: .f4))
        XCTAssertEqual(e4Bitboard.shifted(toward: .west), Bitboard(square: .d4))
        XCTAssertEqual(e4Bitboard.shifted(toward: .northeast), Bitboard(square: .f5))
        XCTAssertEqual(e4Bitboard.shifted(toward: .southeast), Bitboard(square: .f3))
        XCTAssertEqual(e4Bitboard.shifted(toward: .northwest), Bitboard(square: .d5))
        XCTAssertEqual(e4Bitboard.shifted(toward: .southwest), Bitboard(square: .d3))
    }
    
    func testflip() throws {
        XCTAssertEqual(e4Bitboard.flippedVertically(), Bitboard(square: .e5))
        XCTAssertEqual(e4Bitboard.flippedHorizontally(), Bitboard(square: .d4))
    }
    
    func testMutableFlip() throws {
        var horizontalFlip = e4Bitboard
        horizontalFlip.flipHorizontally()
        XCTAssertEqual(horizontalFlip, Bitboard(square: .d4))
        
        var verticalFlip = e4Bitboard
        verticalFlip.flipVertically()
        XCTAssertEqual(verticalFlip, Bitboard(square: .e5))
    }

    func testMutableShift() throws {
        var shiftBoard = e4Bitboard
        shiftBoard.shift(toward: .north)
        XCTAssertEqual(shiftBoard, Bitboard(square: .e5))
    }
    
    func testFilled() throws {
        XCTAssertEqual(multipleSquareBitboard.filled(toward: .north, stoppers: e4Bitboard), Bitboard(file: .b) | Bitboard(file: .h))
    }
    
    func testFill() throws {
        var filled = multipleSquareBitboard
        filled.fill(toward: .north, stoppers: multipleSquareBitboard)
        XCTAssertEqual(filled, Bitboard(file: .b) | Bitboard(file: .h))
    }
    
    func testSwap() throws {
        var swapBitboard = e4Bitboard
        swapBitboard.swap(.e4, .e5)
        XCTAssertEqual(swapBitboard, Bitboard(square: .e5))
    }
    
    func testPawnAttacks() throws {
        XCTAssertEqual(e4Bitboard.attacks(for: .init(pawn: .white)), Bitboard(squares: [.d5, .f5]))
        XCTAssertEqual(e4Bitboard.attacks(for: .init(pawn: .black)), Bitboard(squares: [.d3, .f3]))
    }
    
    func testKnightAttacks() throws {
        XCTAssertEqual(e4Bitboard.attacks(for: .init(knight: .white)), Bitboard(squares: [.d6, .f6, .g5, .g3, .f2, .d2, .c3, .c5]))
    }
    
    func testBishopAttacks() throws {
        XCTAssertEqual(e4Bitboard.attacks(for: .init(bishop: .white)), Bitboard(squares: [.b1, .c2, .d3, .f5, .g6, .h7, .a8, .b7, .c6, .d5, .f3, .g2, .h1 ]))
        XCTAssertEqual(Bitboard(square: .h7),e4Bitboard.xrayBishopAttacks(occupied: Bitboard(square: .g6), stoppers: Bitboard()))
    }
    
    func testRookAttacks() throws {
        XCTAssertEqual(e4Bitboard.attacks(for: .init(rook: .white)), Bitboard(file: .e) ^ Bitboard(rank: .four))

        XCTAssertEqual(Bitboard(square: .h4),e4Bitboard.xrayRookAttacks(occupied: Bitboard(square: .g4), stoppers: Bitboard()))
    }
    
    func testQueenAttacks() throws {
        XCTAssertEqual(
            e4Bitboard.attacks(for: .init(queen: .white)),
            Bitboard(squares: [.b1, .c2, .d3, .f5, .g6, .h7, .a8, .b7, .c6, .d5, .f3, .g2, .h1 ]) | (Bitboard(file: .e) ^ Bitboard(rank: .four))
            )
    }
    
    func testKingAttacks() throws {
        XCTAssertEqual(e4Bitboard.attacks(for: .init(king: .white)), Bitboard(squares: [.d5, .d4, .d3, .e5, .e3, .f5, .f4, .f3]))
    }
    
    func testIterator() throws {
        let bitboard = multipleSquareBitboard
        XCTAssertEqual(bitboard.underestimatedCount, 2)
        XCTAssertTrue(bitboard.contains(.b1))
        var iterator = bitboard.makeIterator()
        XCTAssertEqual(iterator.next(), .b1)
        XCTAssertEqual(iterator.next(), .h1)
        XCTAssertNil(iterator.next())
    }
    
    func testInitWithMove() {
        XCTAssertEqual(Bitboard(move: Move(start: .c1, end: .c8)), Bitboard(squares: [.c1, .c8]))
    }
    
    func testInitialPawnBoardPositions() throws {
        XCTAssertEqual(Bitboard(startFor: Piece(pawn: .white)), Bitboard(rank: .two))
        XCTAssertEqual(Bitboard(startFor: Piece(pawn: .black)), Bitboard(rank: .seven))
    }
    
    func testInitialKnightBoardPositions() throws {
        XCTAssertEqual(Bitboard(startFor: Piece(knight: .white)), Bitboard(locations: [(file: .b, rank: .one), (file: .g, rank: .one)]))
        XCTAssertEqual(Bitboard(startFor: Piece(knight: .black)), Bitboard(locations: [(file: .b, rank: .eight), (file: .g, rank: .eight)]))
    }
    
    func testInitialBishopBoardPositions() throws {
        XCTAssertEqual(Bitboard(startFor: Piece(bishop: .white)), Bitboard(locations: [(file: .c, rank: .one), (file: .f, rank: .one)]))
        XCTAssertEqual(Bitboard(startFor: Piece(bishop: .black)), Bitboard(locations: [(file: .c, rank: .eight), (file: .f, rank: .eight)]))
    }
    
    func testInitialRookBoardPositions() throws {
        XCTAssertEqual(Bitboard(startFor: Piece(rook: .white)), Bitboard(locations: [(file: .a, rank: .one), (file: .h, rank: .one)]))
        XCTAssertEqual(Bitboard(startFor: Piece(rook: .black)), Bitboard(locations: [(file: .a, rank: .eight), (file: .h, rank: .eight)]))
    }
    
    func testInitialQueenBoardPositions() throws {
        XCTAssertEqual(Bitboard(startFor: Piece(queen: .white)), Bitboard(location: (file: .d, rank: .one)))
        XCTAssertEqual(Bitboard(startFor: Piece(queen: .black)), Bitboard(location: (file: .d, rank: .eight)))
    }
    
    func testInitialKingBoardPositions() throws {
        XCTAssertEqual(Bitboard(startFor: Piece(king: .white)), Bitboard(location: (file: .e, rank: .one)))
        XCTAssertEqual(Bitboard(startFor: Piece(king: .black)), Bitboard(location: (file: .e, rank: .eight)))
    }
    
    func testAscii() throws {
        let result =
        """
          +-----------------+
        8 | . . . . . . . . |
        7 | . . . . . . . . |
        6 | . . . . . . . . |
        5 | . . . . . . . . |
        4 | . . . . 1 . . . |
        3 | . . . . . . . . |
        2 | . . . . . . . . |
        1 | . . . . . . . . |
          +-----------------+
            a b c d e f g h
        """
        XCTAssertEqual(e4Bitboard.ascii, result)
    }

    func testInitFiles() throws {
        let aBitboard = Bitboard(file: .a)
        let bBitboard = aBitboard << 1
        let cBitboard = bBitboard << 1
        let dBitboard = cBitboard << 1
        let eBitboard = dBitboard << 1
        let fBitboard = eBitboard << 1
        let gBitboard = fBitboard << 1
        let hBitboard = gBitboard << 1
        XCTAssertEqual(aBitboard, Bitboard(file: .a))
        XCTAssertEqual(bBitboard, Bitboard(file: .b))
        XCTAssertEqual(cBitboard, Bitboard(file: .c))
        XCTAssertEqual(dBitboard, Bitboard(file: .d))
        XCTAssertEqual(eBitboard, Bitboard(file: .e))
        XCTAssertEqual(fBitboard, Bitboard(file: .f))
        XCTAssertEqual(gBitboard, Bitboard(file: .g))
        XCTAssertEqual(hBitboard, Bitboard(file: .h))
    }

    func testSubscript() throws {
        var emptyBoard = e4Bitboard
        emptyBoard[(file: .e, rank: .four)] = false
        XCTAssertEqual(emptyBoard, Bitboard())
    }

    func testPawnPushes() throws {
        let e4PawnPushesWhite = e4Bitboard.pawnPushes(for: .white, empty: ~(Bitboard.allZeros))
        let e4PawnPushesBlack = e4Bitboard.pawnPushes(for: .black, empty: ~(Bitboard.allZeros))
        XCTAssertEqual(e4PawnPushesWhite, Bitboard(square: .e5))
        XCTAssertEqual(e4PawnPushesBlack, Bitboard(square: .e3))
    }

    func testRanks() throws {
        let ranks = Bitboard(squares: [.a1,.b2, .c3, .d4, .e5, .f6, .g7, .h8]).ranks()
        let result: [UInt8] = [1, 2, 4, 8, 16, 32, 64, 128]
        XCTAssertEqual(ranks, result)
    }
}
