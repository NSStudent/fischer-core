import XCTest
@testable import FischerCore

final class VariantTests: XCTestCase {
    func testIsStandard() throws {
        XCTAssertTrue(Variant.standard.isStandard)
        XCTAssertFalse(Variant.upsideDown.isStandard)
    }
    
    func testIsUpsideDown() throws {
        XCTAssertTrue(Variant.upsideDown.isUpsideDown)
        XCTAssertFalse(Variant.standard.isUpsideDown)
    }
}
