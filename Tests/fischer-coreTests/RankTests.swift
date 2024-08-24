import XCTest
@testable import FischerCore

final class RankTests: XCTestCase {
    func testInit() throws {
        XCTAssertEqual(Rank(index: 0), .one)
        XCTAssertEqual(Rank(rawValue: 1), .one)
        XCTAssertEqual(Rank(1), .one)
    }
    
    func testRankIndex() throws {
        XCTAssertEqual(Rank.one.index, 0)
    }
    
    func testOpposite() throws {
        XCTAssertEqual(Rank.one.opposite(), .eight)
    }
    
    func testDescription() throws {
        XCTAssertEqual(Rank.one.description, "1")
    }
    
    func testComparable() throws {
        XCTAssertTrue(Rank.one < .two)
        XCTAssertFalse(Rank.one > .two)
        XCTAssertFalse(Rank.one == .two)
        XCTAssertTrue(Rank.one == .one)
    }
    
    func testInteger() throws {
        let rank: Rank = 1
        XCTAssertEqual(rank, .one)
    }
}
