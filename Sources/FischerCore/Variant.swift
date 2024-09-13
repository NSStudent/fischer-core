import Foundation

public enum Variant {
    case standard
    case upsideDown

    public var isStandard: Bool {
        return self == .standard
    }

    public var isUpsideDown: Bool {
        return self == .upsideDown
    }
}
