import XCTest
@testable import FischerCore

final class BitboardTests: XCTestCase {
//    func testExample() throws {
//        let bitboard = Bitboard(square: .b1) | (Bitboard(square: .b4)  | Bitboard(square: .h1))
//        print(bitboard.ascii)
//        let noFileA: Bitboard = 0xfefefefefefefefe
//        print(noFileA.ascii)
//        let nBitboard = bitboard << 9 & noFileA
//        print(nBitboard.ascii)
//        print(bitboard.lsbIndex)
//        print(bitboard.msbIndex)
//    }
    
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
        let a1Bitboard = Bitboard(square: .a1)
        XCTAssertEqual(a1Bitboard.lsbIndex, 0)
    }
    
}
