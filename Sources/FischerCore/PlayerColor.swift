import Foundation

public enum PlayerColor: String, CaseIterable, Equatable, Codable {
    case white
    case black
}

extension PlayerColor {
    prefix static func ! (_ value: PlayerColor) -> PlayerColor {
        value.inverse()
    }

    public init?(string: String) {
        switch string {
        case "W", "w": self = .white
        case "B", "b": self = .black
        default: return nil
        }
    }

    public func isWhite() -> Bool {
        self == .white
    }

    public func isBlack() -> Bool {
        self == .black
    }

    public func inverse() -> PlayerColor {
        self.isWhite() ? .black : .white
    }

    public mutating func invert() {
        self = inverse()
    }
}


