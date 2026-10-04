//
//  SANParsingOptions.swift
//  FischerCore
//

/// Options that relax how SAN text is parsed.
///
/// The default parser (``SANMove/init(san:)``) only accepts exact SAN.
/// ``lenient`` accepts the variations found in real-world PGN files,
/// broadcasts and handwritten score sheets.
public struct SANParsingOptions: OptionSet, Hashable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Accepts castling written with zeros (`0-0`, `0-0-0`) or lowercase `o`.
    public static let zeroCastling = SANParsingOptions(rawValue: 1 << 0)

    /// Ignores trailing move annotations glued to the move, such as `!`, `?`,
    /// `!?`, `$1`, `e.p.` or `ep`.
    public static let annotationSuffixes = SANParsingOptions(rawValue: 1 << 1)

    /// Accepts alternative symbols: `:` or `×` for captures, `++` for mate,
    /// promotion without `=` (`e8Q`, `e8(Q)`, `e8/Q`), figurine piece symbols
    /// and surrounding whitespace.
    public static let alternativeSymbols = SANParsingOptions(rawValue: 1 << 2)

    /// Exact SAN only.
    public static let strict: SANParsingOptions = []

    /// Every relaxation.
    public static let lenient: SANParsingOptions = [.zeroCastling, .annotationSuffixes, .alternativeSymbols]
}

public extension SANMove {
    /// Parses SAN text with the given options.
    ///
    /// - Parameters:
    ///   - san: The SAN text, for example `"Nf3"`, `"0-0"` or `"e8Q!"`.
    ///   - options: The relaxations to apply. Use ``SANParsingOptions/lenient``
    ///     for imported text.
    init(san: String, options: SANParsingOptions) throws {
        try self.init(san: san, language: .english, options: options)
    }

    /// Parses SAN text written in `language` with the given options.
    ///
    /// - Parameters:
    ///   - san: The SAN text, for example `"Cf3"` in Spanish.
    ///   - language: The language of the piece letters.
    ///   - options: The relaxations to apply.
    init(san: String, language: SANNotationLanguage, options: SANParsingOptions = .strict) throws {
        let normalized = SANMove.normalize(san, language: language, options: options)
        if let move = FastSANParser.parse(normalized) {
            self = move
        } else {
            self = try SanMoveParser().parse(normalized)
        }
    }

    /// Returns `text` rewritten as exact English SAN according to `options`.
    ///
    /// This is the preprocessing step used by ``init(san:language:options:)``.
    static func normalize(_ text: String, language: SANNotationLanguage = .english, options: SANParsingOptions) -> String {
        var san = text
        if options.contains(.alternativeSymbols) {
            san = san.trimmingWhitespace()
            san = replacingFigurines(in: san)
            san = san.replacingOccurrences(of: "×", with: "x")
                .replacingOccurrences(of: ":", with: "x")
                .replacingOccurrences(of: "++", with: "#")
                .replacingOccurrences(of: "‡", with: "#")
        }
        if options.contains(.annotationSuffixes) {
            san = strippingAnnotationSuffixes(san)
        }
        if options.contains(.zeroCastling) {
            san = normalizedCastling(san)
        }
        san = language.translateToEnglish(san)
        if options.contains(.alternativeSymbols) {
            san = normalizedPromotion(san)
        }
        return san
    }
}

private extension SANMove {
    static func strippingAnnotationSuffixes(_ san: String) -> String {
        var value = Substring(san)
        while true {
            let before = value
            while let last = value.last, last == "!" || last == "?" || last == " " {
                value.removeLast()
            }
            if let dollar = value.lastIndex(of: "$"),
               value[value.index(after: dollar)...].allSatisfy(\.isNumber) {
                value = value[..<dollar]
            }
            for suffix in ["e.p.", "ep", "e.p"] where value.hasSuffix(suffix) {
                value = value.dropLast(suffix.count)
                break
            }
            if value == before { break }
        }
        return String(value)
    }

    static func normalizedCastling(_ san: String) -> String {
        var body = Substring(san)
        var suffix = ""
        while let last = body.last, last == "+" || last == "#" {
            suffix = String(last) + suffix
            body.removeLast()
        }
        let letters = body.map { character -> Character in
            switch character {
            case "0", "o": return "O"
            default: return character
            }
        }
        let normalized = String(letters)
        guard normalized == "O-O" || normalized == "O-O-O" else {
            return san
        }
        return normalized + (suffix.contains("#") ? "#" : suffix.isEmpty ? "" : "+")
    }

    static func normalizedPromotion(_ san: String) -> String {
        // e8Q, e8(Q), e8/Q -> e8=Q
        var characters = Array(san)
        var suffix: [Character] = []
        while let last = characters.last, last == "+" || last == "#" {
            suffix.insert(last, at: 0)
            characters.removeLast()
        }
        if characters.last == ")", characters.count >= 4, characters[characters.count - 3] == "(" {
            let piece = characters[characters.count - 2]
            characters.removeLast(3)
            characters += ["=", piece]
        }
        if characters.count >= 4, characters[characters.count - 2] == "/" {
            characters[characters.count - 2] = "="
        }
        if characters.count >= 3,
           let last = characters.last, "QRBN".contains(last),
           characters[characters.count - 2].isNumber {
            characters.insert("=", at: characters.count - 1)
        }
        return String(characters + suffix)
    }

    static func replacingFigurines(in san: String) -> String {
        var output = ""
        for character in san {
            switch character {
            case "♔", "♚": output.append("K")
            case "♕", "♛": output.append("Q")
            case "♖", "♜": output.append("R")
            case "♗", "♝": output.append("B")
            case "♘", "♞": output.append("N")
            case "♙", "♟": continue
            default: output.append(character)
            }
        }
        return output
    }
}

extension String {
    func trimmingWhitespace() -> String {
        var substring = Substring(self)
        while let first = substring.first, first.isWhitespace { substring.removeFirst() }
        while let last = substring.last, last.isWhitespace { substring.removeLast() }
        return String(substring)
    }
}
