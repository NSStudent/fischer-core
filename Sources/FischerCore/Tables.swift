import Foundation

public struct Tables {
    public static func pawnAttackTable(for color: PlayerColor) -> [Bitboard] {
        if color.isWhite() {
            return Tables.whitePawnAttackTable
        } else {
            return blackPawnAttackTable
        }
    }

    public static var whitePawnAttackTable: [Bitboard] = Square.allCases.map { square in
        return Bitboard(square: square).pawnAttacks(for: .white)
    }

    public static var blackPawnAttackTable: [Bitboard] = Square.allCases.map { square in
        return Bitboard(square: square).pawnAttacks(for: .black)
    }

    public static var kingAttackTable: [Bitboard] = Square.allCases.map { square in
        return Bitboard(square: square).kingAttacks()
    }

    /// A lookup table of all knight attack bitboards.
    public static var knightAttackTable: [Bitboard] = Square.allCases.map { square in
        return Bitboard(square: square).knightAttacks()
    }

    public static func between(_ start: Square, _ end: Square) -> Bitboard {
        let start = UInt64(start.rawValue)
        let end = UInt64(end.rawValue)
        let max = UInt64.max
        let a2a7: UInt64 = 0x0001010101010100
        let b2g7: UInt64 = 0x0040201008040200
        let h1b7: UInt64 = 0x0002040810204080

        let between = (max << start) ^ (max << end)
        let file = (end & 7) &- (start & 7)
        let rank = ((end | 7) &- start) >> 3

        var line = ((file & 7) &- 1) & a2a7
        line += 2 &* (((rank & 7) &- 1) >> 58)
        line += (((rank &- file) & 15) &- 1) & b2g7
        line += (((rank &+ file) & 15) &- 1) & h1b7
        line = line &* (between & (0 &- between))

        return Bitboard(rawValue: line & between)
    }

    public static func triangleIndex(_ start: Square, _ end: Square) -> Int {
        var a = start.rawValue
        var b = end.rawValue
        var d = a &- b
        d &= d >> 31
        b = b &+ d
        a = a &- d
        b = b &* (b ^ 127)
        return (b >> 1) + a
    }

    public static var betweenTable: [Bitboard] = {
        var table = [Bitboard](repeating: 0, count: 2080)
        for start in Square.allCases {
            for end in Square.allCases {
                let index = triangleIndex(start, end)
                table[index] = between(start, end)
            }
        }
        return table
    }()

    public static var lineTable: [Bitboard] = {
        var table = [Bitboard](repeating: 0, count: 2080)
        for start in Square.allCases {
            for end in Square.allCases {
                let startBB = Bitboard(square: start)
                let endBB = Bitboard(square: end)
                let index = triangleIndex(start, end)
                let rookAttacks = startBB.rookAttacks()
                let bishopAttacks = startBB.bishopAttacks()
                if rookAttacks[end] {
                    table[index] = startBB | endBB | (rookAttacks & endBB.rookAttacks())
                } else if bishopAttacks[end] {
                    table[index] = startBB | endBB | (bishopAttacks & endBB.bishopAttacks())
                }
            }
        }

        return table
    }()

}
