import Testing
@testable import FischerCore

final class VariantTests {

    @Test("Variant Is Standard")
    func testIsStandard() throws {
        #expect(Variant.standard.isStandard)
        #expect(!Variant.chess960.isStandard)
    }
}
