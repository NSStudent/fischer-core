import XCTest
@testable import FischerCore

final class TablesTests: XCTestCase {
    func testTables() throws {
        XCTAssertEqual(Tables.pawnAttackTable(for: .white)[0], Bitboard(squares: [.b2]))
        XCTAssertEqual(Tables.pawnAttackTable(for: .black)[63], Bitboard(squares: [.g7]))
        print(Tables.lineTable[2034].ascii)
        XCTAssertEqual(Tables.lineTable[2034], Bitboard(squares: [.a1, .b2, .c3, .d4, .e5, .f6, .g7, .h8]))
    }
}
