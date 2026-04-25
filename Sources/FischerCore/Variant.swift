import Foundation

public enum Variant: Equatable, Sendable {
    case standard
    case chess960

    public var isStandard: Bool {
        return self == .standard
    }
}
