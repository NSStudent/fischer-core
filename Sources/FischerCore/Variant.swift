import Foundation

public enum Variant: Equatable {
    case standard
    case chess960

    public var isStandard: Bool {
        return self == .standard
    }
}
