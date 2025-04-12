import Foundation

public enum Variant {
    case standard
    case chess960

    public var isStandard: Bool {
        return self == .standard
    }
}
