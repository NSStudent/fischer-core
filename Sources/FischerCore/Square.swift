import Foundation

public enum Square: Int, CaseIterable, Identifiable {
    public enum Color {
        case light
        case dark
    }

    public var id: Int {
        return rawValue
    }

    case a1
    case b1
    case c1
    case d1
    case e1
    case f1
    case g1
    case h1
    case a2
    case b2
    case c2
    case d2
    case e2
    case f2
    case g2
    case h2
    case a3
    case b3
    case c3
    case d3
    case e3
    case f3
    case g3
    case h3
    case a4
    case b4
    case c4
    case d4
    case e4
    case f4
    case g4
    case h4
    case a5
    case b5
    case c5
    case d5
    case e5
    case f5
    case g5
    case h5
    case a6
    case b6
    case c6
    case d6
    case e6
    case f6
    case g6
    case h6
    case a7
    case b7
    case c7
    case d7
    case e7
    case f7
    case g7
    case h7
    case a8
    case b8
    case c8
    case d8
    case e8
    case f8
    case g8
    case h8

    public init(file: File, rank: Rank) {
        self.init(rawValue: file.index + (rank.index << 3))!
    }

    public init(location: Location) {
        self.init(file: location.file, rank: location.rank)
    }

    public var file: File {
        get {
            return File(index: rawValue & 7)!
        }
        set(newFile) {
            self = Square(file: newFile, rank: rank)
        }
    }

    public var rank: Rank {
        get {
            return Rank(index: rawValue >> 3)!
        }
        set(newRank) {
            self = Square(file: file, rank: newRank)
        }
    }

    public var location: Location {
        get {
            return (file, rank)
        }
        set(newLocation) {
            self = Square(location: newLocation)
        }
    }
}

public typealias Location = (file: File, rank: Rank)

extension Square: CustomStringConvertible {
    public var description: String {
        "\(file)\(rank)"
    }
}

extension Square {
    public init?(_ string: String) {
        guard string.count == 2,
              let  fileCharacter = string.first,
              let rankCharacter = string.last else {
            return nil
        }
        guard let file = File(fileCharacter) else {
            return nil
        }
        guard let rank = Int(String(rankCharacter)).flatMap(Rank.init(integerLiteral:)) else {
            return nil
        }
        self.init(file: file, rank: rank)
    }

    public func attacks(for piece: Piece, stoppers: Bitboard = 0) -> Bitboard {
        switch piece.kind {
        case .king:
            return kingAttacks()
        case .knight:
            return knightAttacks()
        case .pawn:
            return pawnAttackTable(for: piece.color)[rawValue]
        default:
            return Bitboard(square: self).attacks(for: piece, stoppers: stoppers)
        }
    }

    public func kingAttacks() -> Bitboard {
        return Tables.kingAttackTable[rawValue]
    }

    public func knightAttacks() -> Bitboard {
        return Tables.knightAttackTable[rawValue]
    }

    internal func pawnAttackTable(for color: PlayerColor) -> [Bitboard] {
        if color.isWhite() {
            return Tables.whitePawnAttackTable
        } else {
            return Tables.blackPawnAttackTable
        }
    }

    public func between(_ other: Square) -> Bitboard {
        return Tables.betweenTable[Tables.triangleIndex(self, other)]
    }
}

extension Square {
    public var color: Square.Color {
        if (self.rawValue % 8 + self.rawValue / 8) % 2 == 0 {
            return .dark
        }
        return Square.Color.light
    }
}

