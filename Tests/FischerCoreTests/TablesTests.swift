import Testing
@testable import FischerCore

final class TablesTests {

    @Test("Tables Pawn Attack Table")
    func testTables() throws {
        #expect(Tables.pawnAttackTable(for: .white)[0] == Bitboard(squares: [.b2]))
        #expect(Tables.pawnAttackTable(for: .black)[63] == Bitboard(squares: [.g7]))
        print(Tables.lineTable[2034].ascii)
        #expect(Tables.lineTable[2034] == Bitboard(squares: [.a1, .b2, .c3, .d4, .e5, .f6, .g7, .h8]))
    }
}
