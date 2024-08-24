import XCTest
@testable import FischerCore

final class FileTests: XCTestCase {
    func testInit() throws {
        XCTAssertEqual(File("a"), .a)
    }
}
