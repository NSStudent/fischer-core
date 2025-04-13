import Foundation

public enum Rank: Int, Equatable {
    public enum Direction {
        case up
        case down
    }

    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight

    public var index: Int {
        rawValue - 1
    }

    public init?(index: Int) {
        self.init(rawValue: index + 1)
    }

    public func opposite() -> Rank {
        Rank(rawValue: 9 - rawValue)!
    }
    
    public init(startFor color: PlayerColor) {
        self = color.isWhite() ? 1 : 8
    }

    public init(endFor color: PlayerColor) {
        self = color.isWhite() ? 8 : 1
    }
}

extension Rank: CaseIterable {}

extension Rank: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}

extension Rank: Comparable {
    public static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Rank: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        guard let rank = Rank(rawValue: value) else {
            fatalError("Rank value not within 1 and 8, inclusive")
        }
        self = rank
    }
}
