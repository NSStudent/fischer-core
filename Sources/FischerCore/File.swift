import Foundation

public enum File: Int {

    public enum Direction {
        case left
        case right
    }

    case a = 1
    case b
    case c
    case d
    case e
    case f
    case g
    case h

    public var index: Int {
        rawValue - 1
    }

    public init?(index: Int) {
        self.init(rawValue: index + 1)
    }

    public var stringValue: String {
        switch self {
        case .a: return "a"
        case .b: return "b"
        case .c: return "c"
        case .d: return "d"
        case .e: return "e"
        case .f: return "f"
        case .g: return "g"
        case .h: return "h"
        }
    }

    public func opposite() -> File {
        return File(rawValue: 9 - rawValue)!
    }
}

extension File: CaseIterable {}

extension File: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}

extension File: Comparable {
    public static func < (lhs: File, rhs: File) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension File: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        switch value {
        case "a":
            self = .a
        case "b":
            self = .b
        case "c":
            self = .c
        case "d":
            self = .d
        case "e":
            self = .e
        case "f":
            self = .f
        case "g":
            self = .g
        case "h":
            self = .h
        default:
            fatalError("Rank value not within a and h, inclusive")
        }
    }

    init?(string: String) {
        switch string {
        case "a":
            self = .a
        case "b":
            self = .b
        case "c":
            self = .c
        case "d":
            self = .d
        case "e":
            self = .e
        case "f":
            self = .f
        case "g":
            self = .g
        case "h":
            self = .h
        default:
            return nil
        }
    }
}

extension File {
    public init?(_ character: Character) {
        switch character {
        case "A", "a": self = .a
        case "B", "b": self = .b
        case "C", "c": self = .c
        case "D", "d": self = .d
        case "E", "e": self = .e
        case "F", "f": self = .f
        case "G", "g": self = .g
        case "H", "h": self = .h
        default: return nil
        }
    }
}

