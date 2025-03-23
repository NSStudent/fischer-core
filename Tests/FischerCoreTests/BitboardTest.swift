import Testing
@testable import FischerCore

final class BitboardTests {

    let multipleSquareBitboard = Bitboard(squares: [.b1, .h1])
    let e4Bitboard = Bitboard(location:(file: .e, rank: .four))

    @Test("Bitboard Basic Init")
    func testBasicInit() {
        #expect(Bitboard() == Bitboard(rawValue: 0))
    }

    @Test("Bitboard Operators")
    func testOperators() throws {
        let bitboard = Bitboard(square: .e4)
        var mBitboard = bitboard
        #expect(bitboard << 1 == Bitboard(square: .f4))
        #expect(bitboard >> 1 == Bitboard(square: .d4))
        mBitboard <<= 1
        #expect(mBitboard == Bitboard(square: .f4))
        mBitboard >>= 1
        #expect(mBitboard == Bitboard(square: .e4))

        #expect(Bitboard(file: .a) & Bitboard(rank: 1) == Bitboard(square: .a1))
        #expect(Bitboard(file: .a) ^ Bitboard(rank: .one) == (Bitboard(file: .a) | Bitboard(rank: .one)) & (~Bitboard(square: .a1)))
    }

    @Test("Bitboard Comparable Operators")
    func testComparableOperators() throws {
        let a1Bitboard = Bitboard(square: .a1)
        let h8Bitboard = Bitboard(square: .h8)
        #expect(a1Bitboard < h8Bitboard)
        #expect(h8Bitboard > a1Bitboard)
    }

    @Test("Bitboard LSB Index")
    func testLSBIndex() throws {
        #expect(multipleSquareBitboard.lsbIndex == 1)
        #expect(multipleSquareBitboard.lsbSquare == .b1)
    }

    @Test("Bitboard MSB Index")
    func testMSBIndex() throws {
        #expect(Bitboard().msbIndex == nil)
        #expect(multipleSquareBitboard.msbIndex == 7)
        #expect(multipleSquareBitboard.msbSquare == .h1)
    }

    @Test("Bitboard Pop LSB Bitboard")
    func testPopLSBBitboard() throws {
        var popLSBBitboard = multipleSquareBitboard
        let popedLSB = popLSBBitboard.popLSB()
        #expect(popLSBBitboard == Bitboard(square: .h1))
        #expect(popedLSB == Bitboard(square: .b1))
    }

    @Test("Bitboard Pop MSB Bitboard")
    func testPopMSBBitboard() throws {
        var popMSBBitboard = multipleSquareBitboard
        let popedMSB = popMSBBitboard.popMSB()
        #expect(popMSBBitboard == Bitboard(square: .b1))
        #expect(popedMSB == Bitboard(square: .h1))
    }

    @Test("Bitboard isEmpty")
    func testIsEmpty() throws {
        #expect(Bitboard().isEmpty)
        #expect(!multipleSquareBitboard.isEmpty)
    }

    @Test("Bitboard Has More Than One")
    func testHasMoreThanOne() throws {
        #expect(!Bitboard().hasMoreThanOne)
        #expect(multipleSquareBitboard.hasMoreThanOne)
    }

    @Test("Bitboard Count")
    func testCount() throws {
        #expect(multipleSquareBitboard.count == 2)
        #expect(Bitboard(file: .a).count == 8)
    }

    @Test("Bitboard Shift")
    func testShift() throws {
        #expect(e4Bitboard.shifted(toward: .north) == Bitboard(square: .e5))
        #expect(e4Bitboard.shifted(toward: .south) == Bitboard(square: .e3))
        #expect(e4Bitboard.shifted(toward: .east) == Bitboard(square: .f4))
        #expect(e4Bitboard.shifted(toward: .west) == Bitboard(square: .d4))
    }

    @Test("Bitboard Flip")
    func testflip() throws {
        #expect(e4Bitboard.flippedVertically() == Bitboard(square: .e5))
        #expect(e4Bitboard.flippedHorizontally() == Bitboard(square: .d4))
    }

    @Test("Bitboard Mutable Shift")
    func testMutableShift() throws {
        var shiftBoard = e4Bitboard
        shiftBoard.shift(toward: .north)
        #expect(shiftBoard == Bitboard(square: .e5))
    }

    @Test("Bitboard Iterator")
    func testIterator() throws {
        let bitboard = multipleSquareBitboard
        #expect(bitboard.underestimatedCount == 2)
        #expect(bitboard.contains(.b1))
        var iterator = bitboard.makeIterator()
        #expect(iterator.next() == .b1)
        #expect(iterator.next() == .h1)
        #expect(iterator.next() == nil)
    }

    @Test("Bitboard Init With Move")
    func testInitWithMove() {
        #expect(Bitboard(move: Move(start: .c1, end: .c8)) == Bitboard(squares: [.c1, .c8]))
    }
}
