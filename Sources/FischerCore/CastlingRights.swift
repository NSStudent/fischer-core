import Foundation

public struct CastlingRights {
    public enum Right: String, CaseIterable, CustomStringConvertible {
        case whiteKingside
        case whiteQueenside
        case blackKingside
        case blackQueenside

        public static let white: [Right] = allCases.filter({ $0.color.isWhite() })

        public static let black: [Right] = allCases.filter({ $0.color.isBlack() })

        public static let kingside: [Right] = allCases.filter({ $0.side.isKingside })

        public static let queenside: [Right] = allCases.filter({ $0.side.isQueenside })

        public var description: String {
            return rawValue
        }

        public var stringValue: String {
            switch self {
            case .whiteKingside:  return "K"
            case .whiteQueenside: return "Q"
            case .blackKingside:  return "k"
            case .blackQueenside: return "q"
            }
        }

        var color: PlayerColor {
            get {
                switch self {
                case .whiteKingside, .whiteQueenside:
                    return .white
                default:
                    return .black
                }
            }
            set {
                self = Right(color: newValue, side: side)
            }
        }

        public var side: Board.Side {
            get {
                switch self {
                case .whiteKingside, .blackKingside:
                    return .kingside
                default:
                    return .queenside
                }
            }
            set {
                self = Right(color: color, side: newValue)
            }
        }

        public var emptySquares: Bitboard {
            switch self {
            case .whiteKingside:
                return 0b01100000
            case .whiteQueenside:
                return 0b00001110
            case .blackKingside:
                return 0b01100000 << 56
            case .blackQueenside:
                return 0b00001110 << 56
            }
        }

        public var castleSquare: Square {
            switch self {
            case .whiteKingside:
                return .g1
            case .whiteQueenside:
                return .c1
            case .blackKingside:
                return .g8
            case .blackQueenside:
                return .c8
            }
        }

        public init(color: PlayerColor, side: Board.Side) {
            switch (color, side) {
            case (.white, .kingside):  self = .whiteKingside
            case (.white, .queenside): self = .whiteQueenside
            case (.black, .kingside):  self = .blackKingside
            case (.black, .queenside): self = .blackQueenside
            }
        }

        public init?(string: String) {
            switch string {
            case "K": self = .whiteKingside
            case "Q": self = .whiteQueenside
            case "k": self = .blackKingside
            case "q": self = .blackQueenside
            default: return nil
            }
        }
    }

    public struct Iterator: IteratorProtocol {

        fileprivate var base: SetIterator<Right>

        public mutating func next() -> Right? {
            return base.next()
        }

    }

    public static let all = CastlingRights(Right.allCases)

    public static let white = CastlingRights(Right.white)

    public static let black = CastlingRights(Right.black)

    public static let kingside = CastlingRights(Right.kingside)

    public static let queenside = CastlingRights(Right.queenside)

    fileprivate var rights: Set<Right>

    public var description: String {
        if !rights.isEmpty {
            return rights.map({ $0.stringValue }).sorted().joined(separator: "")
        } else {
            return "-"
        }
    }

    public init() {
        rights = Set()
    }

    public init?(string: String) {
        guard !string.isEmpty else {
            return nil
        }
        if string == "-" {
            rights = Set()
        } else {
            var rights = Set<Right>()
            for char in string {
                guard let right = Right(string: String(char)) else {
                    return nil
                }
                rights.insert(right)
            }
            self.rights = rights
        }
    }

    /// Creates castling rights for `color`.
    public init(color: PlayerColor) {
        self = color.isWhite() ? .white : .black
    }

    public init(side: Board.Side) {
        self = side.isKingside ? .kingside : .queenside
    }

    public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Right {
        if let set = sequence as? Set<Right> {
            rights = set
        } else {
            rights = Set(sequence)
        }
    }
}

extension CastlingRights: Sequence {
    public func makeIterator() -> Iterator {
        return Iterator(base: rights.makeIterator())
    }
}

extension CastlingRights: SetAlgebra {

    /// A Boolean value that indicates whether the set has no elements.
    public var isEmpty: Bool {
        return rights.isEmpty
    }

    /// Returns a Boolean value that indicates whether the given element exists
    /// in the set.
    public func contains(_ member: Right) -> Bool {
        return rights.contains(member)
    }

    /// Returns a new set with the elements of both this and the given set.
    public func union(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(rights.union(other.rights))
    }

    /// Returns a new set with the elements that are common to both this set and
    /// the given set.
    public func intersection(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(rights.intersection(other.rights))
    }

    /// Returns a new set with the elements that are either in this set or in the
    /// given set, but not in both.
    public func symmetricDifference(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(rights.symmetricDifference(other.rights))
    }

    /// Inserts the given element in the set if it is not already present.
    @discardableResult
    public mutating func insert(_ newMember: Right) -> (inserted: Bool, memberAfterInsert: Right) {
        return rights.insert(newMember)
    }

    /// Removes the given element and any elements subsumed by the given element.
    @discardableResult
    public mutating func remove(_ member: Right) -> Right? {
        return rights.remove(member)
    }

    /// Inserts the given element into the set unconditionally.
    @discardableResult
    public mutating func update(with newMember: Right) -> Right? {
        return rights.update(with: newMember)
    }

    /// Adds the elements of the given set to the set.
    public mutating func formUnion(_ other: CastlingRights) {
        rights.formUnion(other.rights)
    }

    /// Removes the elements of this set that aren't also in the given set.
    public mutating func formIntersection(_ other: CastlingRights) {
        rights.formIntersection(other.rights)
    }

    /// Removes the elements of the set that are also in the given set and
    /// adds the members of the given set that are not already in the set.
    public mutating func formSymmetricDifference(_ other: CastlingRights) {
        rights.formSymmetricDifference(other.rights)
    }

    /// Returns a new set containing the elements of this set that do not occur
    /// in the given set.
    public func subtracting(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(rights.subtracting(other.rights))
    }

    /// Returns a Boolean value that indicates whether the set is a subset of
    /// another set.
    public func isSubset(of other: CastlingRights) -> Bool {
        return rights.isSubset(of: other.rights)
    }

    /// Returns a Boolean value that indicates whether the set has no members in
    /// common with the given set.
    public func isDisjoint(with other: CastlingRights) -> Bool {
        return rights.isDisjoint(with: other.rights)
    }

    /// Returns a Boolean value that indicates whether the set is a superset of
    /// the given set.
    public func isSuperset(of other: CastlingRights) -> Bool {
        return rights.isSuperset(of: other.rights)
    }

    /// Removes the elements of the given set from this set.
    public mutating func subtract(_ other: CastlingRights) {
        rights.subtract(other)
    }

}
