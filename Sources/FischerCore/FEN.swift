//
//  FEN.swift
//  FischerCore
//

/// Helpers for working with Forsyth-Edwards Notation strings.
public enum FEN {
    /// Returns the piece-placement field from either a full FEN string or an
    /// already-trimmed placement string.
    public static func placement(from fenOrPlacement: String) -> String {
        fenOrPlacement
            .split(separator: " ", maxSplits: 1)
            .first
            .map(String.init) ?? fenOrPlacement
    }
}
