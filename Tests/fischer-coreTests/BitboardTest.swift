import XCTest
@testable import FischerCore

final class BitboardTests: XCTestCase {
    
    let multipleSquareBitboard = Bitboard(squares: [.b1, .h1])
    let e4Bitboard = Bitboard(square: .e4)
    
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
    }
    
    func testRookAttacks() throws {
        XCTAssertEqual(e4Bitboard.attacks(for: .init(rook: .white)), Bitboard(file: .e) ^ Bitboard(rank: .four))
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
}
