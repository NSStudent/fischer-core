//
//  SANNotationLanguage.swift
//  FischerCore
//

/// The language used for the piece letters of a SAN move.
///
/// Only the piece letters change between languages. Squares, captures,
/// castling and check symbols are the same.
///
/// | Piece  | English | Spanish |
/// |--------|---------|---------|
/// | King   | K       | R       |
/// | Queen  | Q       | D       |
/// | Rook   | R       | T       |
/// | Bishop | B       | A       |
/// | Knight | N       | C       |
public enum SANNotationLanguage: String, CaseIterable, Codable, Hashable, Sendable {
    case english
    case spanish

    /// The piece letter for `kind`, or an empty string for pawns.
    public func letter(for kind: Piece.Kind) -> String {
        switch (self, kind) {
        case (_, .pawn): return ""
        case (.english, .king): return "K"
        case (.english, .queen): return "Q"
        case (.english, .rook): return "R"
        case (.english, .bishop): return "B"
        case (.english, .knight): return "N"
        case (.spanish, .king): return "R"
        case (.spanish, .queen): return "D"
        case (.spanish, .rook): return "T"
        case (.spanish, .bishop): return "A"
        case (.spanish, .knight): return "C"
        }
    }

    /// The piece kind for an uppercase piece letter in this language.
    ///
    /// `P` (and Spanish `P` for *peón*) maps to `.pawn`.
    public func pieceKind(for letter: Character) -> Piece.Kind? {
        if letter == "P" {
            return .pawn
        }
        return Piece.Kind.allCases.first { kind in
            kind != .pawn && self.letter(for: kind) == String(letter)
        }
    }

    /// Translates the piece letters of `san` from this language to English.
    ///
    /// Only uppercase piece letters are translated, so file letters and
    /// castling (`O-O`) are left untouched. A leading pawn letter (`P`) is
    /// removed. Text that is already English is returned unchanged when the
    /// language is `.english`.
    ///
    /// ```swift
    /// SANNotationLanguage.spanish.translateToEnglish("Cxe5+") // "Nxe5+"
    /// SANNotationLanguage.spanish.translateToEnglish("e8=D")  // "e8=Q"
    /// ```
    public func translateToEnglish(_ san: String) -> String {
        translate(san, from: self, to: .english)
    }

    /// Translates the piece letters of an English `san` into this language.
    public func translateFromEnglish(_ san: String) -> String {
        translate(san, from: .english, to: self)
    }

    private func translate(_ san: String, from source: SANNotationLanguage, to target: SANNotationLanguage) -> String {
        guard source != target else { return san }
        var output = ""
        var isFirst = true
        for character in san {
            defer { isFirst = false }
            guard character.isUppercase, character != "O" else {
                output.append(character)
                continue
            }
            guard let kind = source.pieceKind(for: character) else {
                output.append(character)
                continue
            }
            if kind == .pawn {
                // A leading pawn letter is optional in SAN; drop it.
                if !isFirst { output.append(character) }
                continue
            }
            output += target.letter(for: kind)
        }
        return output
    }
}

/// Translates the piece letters of a SAN string from `language` to English.
///
/// Convenience wrapper over ``SANNotationLanguage/translateToEnglish(_:)``.
public func translateToEnglish(_ san: String, from language: SANNotationLanguage) -> String {
    language.translateToEnglish(san)
}
