import Foundation

public enum PlayerColor: String, CaseIterable, Equatable, Codable {
    case white
    case black
}

extension PlayerColor {
    prefix static func ! (_ value: PlayerColor) -> PlayerColor {
        switch value {
        case .white:
            return .black
        case .black:
            return .white
        }
    }

    public init?(string: String) {
        switch string {
        case "W", "w": self = .white
        case "B", "b": self = .black
        default: return nil
        }
    }

    public func isWhite() -> Bool {
        return self == .white
    }

    public func isBlack() -> Bool {
        return self == .black
    }

    public func inverse() -> PlayerColor {
        return self.isWhite() ? .black : .white
    }

    public mutating func invert() {
        self = inverse()
    }
}


