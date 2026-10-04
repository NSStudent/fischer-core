//
//  NotationMove.swift
//  FischerCore
//

/// Helpers for writing moves in notations other than SAN.
public enum NotationMove {
    /// Long algebraic notation, for example `"Ng1-f3"`, `"e2-e4"`,
    /// `"Bb5xc6+"` or `"e7-e8=Q"`.
    ///
    /// - Parameters:
    ///   - from: The origin square.
    ///   - to: The destination square.
    ///   - piece: The moving piece kind.
    ///   - promotion: The promotion piece, if any.
    ///   - isCapture: Whether the move captures (uses `x` instead of `-`).
    ///   - isCheck: Whether to append `+`.
    ///   - isCheckmate: Whether to append `#`.
    ///   - language: The language of the piece letters.
    public static func long(
        from: Square,
        to: Square,
        piece: Piece.Kind,
        promotion: PromotionPiece? = nil,
        isCapture: Bool = false,
        isCheck: Bool = false,
        isCheckmate: Bool = false,
        language: SANNotationLanguage = .english
    ) -> String {
        var text = language.letter(for: piece)
        text += from.description
        text += isCapture ? "x" : "-"
        text += to.description
        if let promotion {
            text += "=" + language.letter(for: promotion.kind)
        }
        text += SANMove.checkSuffix(isCheck: isCheck, isCheckmate: isCheckmate)
        return text
    }
}
