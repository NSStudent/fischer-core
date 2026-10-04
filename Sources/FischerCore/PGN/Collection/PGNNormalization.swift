//
//  PGNNormalization.swift
//  FischerCore
//

/// Normalized forms of PGN games used to detect duplicates.
public enum PGNNormalization {
    /// The current version of the content hash. It is part of the hashed
    /// text, so changing the normalization changes every hash.
    public static let contentHashVersion = 1

    /// Reduces movetext to its main line SAN moves separated by one space.
    ///
    /// Removes comments (`{}` and `;`), escape lines (`%`), variations, NAGs
    /// and annotation glyphs, move numbers, the result marker and the check
    /// and mate markers, and writes castling with the letter `O`. Two
    /// exports of the same game that differ only in formatting or
    /// annotations produce the same text.
    ///
    /// ```swift
    /// PGNNormalization.normalizedMovetext("1.e4 {best} e5 (1...c5) 2. Nf3!? 1-0")
    /// // "e4 e5 Nf3"
    /// ```
    public static func normalizedMovetext(_ movetext: String) -> String {
        var moves: [String] = []
        var token = ""
        var braceDepth = 0
        var variationDepth = 0
        var inLineComment = false
        var atLineStart = true
        var inEscapeLine = false

        func flush() {
            defer { token = "" }
            guard variationDepth == 0, let move = normalizedMoveToken(token) else { return }
            moves.append(move)
        }

        for character in movetext {
            if character == "\n" || character == "\r" {
                inLineComment = false
                inEscapeLine = false
                atLineStart = true
                if braceDepth == 0 { flush() }
                continue
            }
            defer { atLineStart = false }
            if inLineComment || inEscapeLine { continue }
            if braceDepth > 0 {
                if character == "}" { braceDepth = 0 }
                continue
            }
            switch character {
            case "%" where atLineStart:
                inEscapeLine = true
            case "{":
                flush()
                braceDepth = 1
            case ";":
                flush()
                inLineComment = true
            case "(":
                flush()
                variationDepth += 1
            case ")":
                flush()
                variationDepth = max(0, variationDepth - 1)
            case _ where character.isWhitespace:
                flush()
            default:
                token.append(character)
            }
        }
        flush()
        return moves.joined(separator: " ")
    }

    /// A stable hash identifying the game, for duplicate detection.
    ///
    /// The hash covers the normalized main line (see
    /// ``normalizedMovetext(_:)``), the `FEN` tag when present and, when
    /// `includeTags` is `true`, the `White`, `Black`, `Date` and `Result`
    /// tags (trimmed, whitespace collapsed, case-insensitive). It does not
    /// change with whitespace, line endings, comments, NAGs, variations,
    /// move number style, tag order or other tags.
    ///
    /// - Returns: 16 lowercase hexadecimal digits.
    public static func contentHash(movetext: String, tags: [PGNTag: String], includeTags: Bool = true) -> String {
        contentHash(normalizedMovetext: normalizedMovetext(movetext), tags: tags, includeTags: includeTags)
    }

    static func contentHash(normalizedMovetext: String, tags: [PGNTag: String], includeTags: Bool) -> String {
        var fields = ["v\(contentHashVersion)"]
        if includeTags {
            for tag in [PGNTag.white, .black, .date, .result] {
                fields.append(normalizedTagValue(tags[tag]))
            }
        }
        let fen = tags[.fen].map(MoveAnnotations.normalizedText) ?? ""
        fields.append(fen)
        fields.append(normalizedMovetext)
        return PGNHash.fnv1a64Hex(fields.joined(separator: "\u{1F}"))
    }

    static func normalizedTagValue(_ value: String?) -> String {
        guard let value else { return "" }
        let normalized = MoveAnnotations.normalizedText(value).lowercased()
        return normalized == "?" || normalized == "????.??.??" ? "" : normalized
    }

    /// Returns the SAN of a movetext token, or `nil` for move numbers,
    /// results, NAGs and other non-move tokens.
    static func normalizedMoveToken(_ raw: String) -> String? {
        var token = Substring(raw)
        // Move numbers, possibly glued to the move: "12.", "12...", "12.Nf3".
        let digits = token.prefix(while: \.isNumber)
        if !digits.isEmpty {
            let afterDigits = token.dropFirst(digits.count)
            let dots = afterDigits.prefix { $0 == "." }
            if !dots.isEmpty {
                token = afterDigits.dropFirst(dots.count)
            }
        }
        guard !token.isEmpty else { return nil }
        if ["1-0", "0-1", "1/2-1/2", "*", "½-½"].contains(String(token)) { return nil }
        if token.first == "$" { return nil }

        var move = String(token)
        if let dollar = move.firstIndex(of: "$") {
            move = String(move[..<dollar])
        }
        move = SANMove.normalize(move, options: [.annotationSuffixes, .zeroCastling])
        while let last = move.last, last == "+" || last == "#" {
            move.removeLast()
        }
        guard let first = move.first, first.isLetter else { return nil }
        return move
    }
}

public extension BasicPGNGame {
    /// The main line SAN moves of the game, normalized. See
    /// ``PGNNormalization/normalizedMovetext(_:)``.
    var normalizedMovetext: String {
        PGNNormalization.normalizedMovetext(movetext)
    }

    /// A stable hash identifying the game. See
    /// ``PGNNormalization/contentHash(movetext:tags:includeTags:)``.
    func contentHash(includeTags: Bool = true) -> String {
        PGNNormalization.contentHash(movetext: movetext, tags: tags, includeTags: includeTags)
    }
}

public extension AnnotatedPGNGame {
    /// The main line SAN moves of the game, normalized the same way as
    /// imported text, so it can be compared with ``BasicPGNGame``.
    var normalizedMovetext: String {
        PGNNormalization.normalizedMovetext(
            tree.mainline.map(\.node.san.description).joined(separator: " ")
        )
    }

    /// A stable hash identifying the game, equal to the hash of the same
    /// game imported as text. See
    /// ``PGNNormalization/contentHash(movetext:tags:includeTags:)``.
    func contentHash(includeTags: Bool = true) -> String {
        var hashTags = tags
        hashTags[.result] = result.rawValue
        if !tree.startsFromStandardPosition, hashTags[.fen] == nil {
            hashTags[.fen] = tree.initialFEN
        }
        return PGNNormalization.contentHash(
            normalizedMovetext: normalizedMovetext,
            tags: hashTags,
            includeTags: includeTags
        )
    }
}
