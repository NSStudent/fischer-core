import XCTest
@testable import FischerCore

final class PlayerColorTests: XCTestCase {
    func testInit() throws {
        XCTAssertEqual(PlayerColor.init(string: "w"), .white)
        XCTAssertEqual(PlayerColor.init(string: "W"), .white)
        XCTAssertEqual(PlayerColor.init(string: "b"), .black)
        XCTAssertEqual(PlayerColor.init(string: "B"), .black)
        XCTAssertNil(PlayerColor.init(string: "x"))
    }
    
    func testInfixOperator() throws {
        XCTAssertEqual(!PlayerColor.white, .black)
        XCTAssertEqual(!PlayerColor.black, .white)
    }
    
    func testIsWhite() throws {
        XCTAssertTrue(PlayerColor.white.isWhite())
        XCTAssertFalse(PlayerColor.black.isWhite())
    }
    
    func testIsBlack() throws {
        XCTAssertTrue(PlayerColor.black.isBlack())
        XCTAssertFalse(PlayerColor.white.isBlack())
    }
    
    func testInverse() throws {
        XCTAssertEqual(PlayerColor.white.inverse(), .black)
        XCTAssertEqual(PlayerColor.black.inverse(), .white)
    }
    
    func testInvert() throws {
        var whiteInverted = PlayerColor.white
        whiteInverted.invert()
        var blackInverted = PlayerColor.black
        blackInverted.invert()
        XCTAssertEqual(whiteInverted, .black)
        XCTAssertEqual(blackInverted, .white)
    }
}
