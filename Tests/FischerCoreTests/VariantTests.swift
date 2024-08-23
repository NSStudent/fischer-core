import Testing
@testable import FischerCore

final class VariantTests {

    @Test("Variant Is Standard")
    func testIsStandard() throws {
        #expect(Variant.standard.isStandard)
        #expect(!Variant.upsideDown.isStandard)
    }

    @Test("Variant Is Upside Down")
    func testIsUpsideDown() throws {
        #expect(Variant.upsideDown.isUpsideDown)
        #expect(!Variant.standard.isUpsideDown)
    }
}
