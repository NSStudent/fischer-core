//
//  SANResolutionError.swift
//  FischerCore
//

/// The reason a SAN move could not be resolved against a position.
///
/// Returned by ``Game/resolve(_:strict:)``.
public enum SANResolutionError: Error, Equatable, Hashable, Sendable, CustomStringConvertible {
    /// The text is not valid SAN, even with lenient parsing.
    case invalidNotation(String)

    /// The side to move has no piece of the given kind (matching the
    /// disambiguation) that could make the move.
    case notFound

    /// A matching piece exists, but the move is not legal in the position
    /// (for example, it is blocked, pinned or leaves the king in check).
    case illegal

    /// More than one legal move matches the SAN. The candidates are listed.
    case ambiguous([ResolvedMove])

    /// The move promotes a pawn but the SAN does not say to which piece.
    /// Only reported in strict mode; lenient mode promotes to a queen.
    case missingPromotion

    /// The SAN includes a promotion but the move does not promote.
    /// Only reported in strict mode.
    case unexpectedPromotion

    /// The capture marker (`x`) does not match the move.
    /// Only reported in strict mode.
    case captureMismatch

    /// The check (`+`) or mate (`#`) marker does not match the move.
    /// Only reported in strict mode.
    case checkMismatch

    public var description: String {
        switch self {
        case let .invalidNotation(text):
            return "Invalid SAN notation: \(text)"
        case .notFound:
            return "No piece can make this move"
        case .illegal:
            return "Illegal move"
        case let .ambiguous(candidates):
            return "Ambiguous move: \(candidates.map(\.uci).joined(separator: ", "))"
        case .missingPromotion:
            return "Missing promotion piece"
        case .unexpectedPromotion:
            return "The move does not promote"
        case .captureMismatch:
            return "Capture marker does not match the move"
        case .checkMismatch:
            return "Check marker does not match the move"
        }
    }
}

/// An error raised while replaying a list of SAN moves.
public struct SANReplayError: Error, Equatable, Sendable, CustomStringConvertible {
    /// Zero-based ply index of the move that failed.
    public let ply: Int
    /// The SAN text that failed.
    public let san: String
    /// Why it failed.
    public let reason: SANResolutionError

    public init(ply: Int, san: String, reason: SANResolutionError) {
        self.ply = ply
        self.san = san
        self.reason = reason
    }

    public var description: String {
        "Ply \(ply) (\(san)): \(reason)"
    }
}
