import XCTest
@testable import FischerCore

final class FileTests: XCTestCase {
    func testInit() throws {
        XCTAssertEqual(File("a"), .a)
        XCTAssertEqual(File("b"), .b)
        XCTAssertEqual(File("c"), .c)
        XCTAssertEqual(File("d"), .d)
        XCTAssertEqual(File("e"), .e)
        XCTAssertEqual(File("f"), .f)
        XCTAssertEqual(File("g"), .g)
        XCTAssertEqual(File("h"), .h)
        
        
        XCTAssertEqual(File(Character("a")), .a)
        XCTAssertEqual(File(Character("b")), .b)
        XCTAssertEqual(File(Character("c")), .c)
        XCTAssertEqual(File(Character("d")), .d)
        XCTAssertEqual(File(Character("e")), .e)
        XCTAssertEqual(File(Character("f")), .f)
        XCTAssertEqual(File(Character("g")), .g)
        XCTAssertEqual(File(Character("h")), .h)
        
        XCTAssertEqual(File(index: 7), .h)
    }
    
    func testOposite() throws {
        XCTAssertEqual(File.a.opposite(), .h)
    }
    
    func testDescription() throws {
        XCTAssertEqual(File.a.description, "a")
    }
    
    func testComparable() throws {
        XCTAssertTrue(File.a < .b)
        XCTAssertFalse(File.a > .b)
        XCTAssertFalse(File.a == .b)
        XCTAssertTrue(File.a == .a)
    }
    
    func testIndex() throws {
        XCTAssertEqual(File("a").index, 0)
    }

}
