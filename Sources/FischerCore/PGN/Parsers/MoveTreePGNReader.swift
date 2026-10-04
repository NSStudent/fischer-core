//
//  MoveTreePGNReader.swift
//  FischerCore
//
//  Created by Omar Megdadi on 21/3/26.
//

import Foundation
import Parsing

public struct MoveTreePGNReader {
    public enum ReaderError: Error, Equatable {
        case unterminatedTag
        case unterminatedVariation
        case unexpectedVariation
    }

    private var input: Substring

    public init(_ pgn: String) {
        self.input = pgn[...]
    }

    public mutating func readGame() throws -> MoveTreePGN? {
        guard let raw = try readRawGame(parsesInitialComment: true) else {
            return nil
        }

        return MoveTreePGN(
            tags: raw.tags,
            initialComment: raw.initialComment,
            tree: raw.line.head?.freeze(),
            result: raw.line.result
        )
    }

    public mutating func readGames() throws -> [MoveTreePGN] {
        var games: [MoveTreePGN] = []
        while let game = try readGame() {
            games.append(game)
        }
        return games
    }

    /// Reads the next game into an ``AnnotatedPGNGame``, keeping NAGs,
    /// comments, comment commands and variations, with every move resolved.
    ///
    /// In lenient mode (the default) a move that cannot be played ends its
    /// line and is reported in ``AnnotatedPGNGame/issues``; in strict mode it
    /// throws ``AnnotatedPGNError/illegalMove(_:)``.
    ///
    /// - Returns: The game, or `nil` at the end of the input.
    public mutating func readAnnotatedGame(strict: Bool = false) throws -> AnnotatedPGNGame? {
        guard let raw = try readRawGame(parsesInitialComment: false) else {
            return nil
        }
        return try AnnotatedPGNGame(raw: raw, strict: strict)
    }

    /// Reads every remaining game as ``AnnotatedPGNGame`` values.
    public mutating func readAnnotatedGames(strict: Bool = false) throws -> [AnnotatedPGNGame] {
        var games: [AnnotatedPGNGame] = []
        while let game = try readAnnotatedGame(strict: strict) {
            games.append(game)
        }
        return games
    }
}

struct RawPGNGame {
    let tags: [PGNTag: String]
    let tagOrder: [PGNTag]
    let initialComment: [PGNComment]?
    let line: RawPGNLine
}

struct RawPGNLine {
    let head: RawPGNNode?
    let leadingComments: [Substring]
    let result: PGNOutcome?
}

final class RawPGNNode {
    let turn: UInt
    let color: PlayerColor
    let move: SANMove
    var annotations = MoveAnnotations()
    var next: RawPGNNode?
    var variants: [RawPGNNode]

    init(
        turn: UInt,
        color: PlayerColor,
        move: SANMove,
        next: RawPGNNode? = nil,
        variants: [RawPGNNode] = []
    ) {
        self.turn = turn
        self.color = color
        self.move = move
        self.next = next
        self.variants = variants
    }

    func freeze() -> MoveTree {
        MoveTree(
            turn: turn,
            color: color,
            node: move,
            next: next?.freeze(),
            variants: variants.map { $0.freeze() }
        )
    }
}

private extension MoveTreePGNReader {
    typealias NodeBuilder = RawPGNNode
    typealias ParsedLine = RawPGNLine

    mutating func readRawGame(parsesInitialComment: Bool) throws -> RawPGNGame? {
        skipLeadingNoise()

        guard !input.isEmpty else {
            return nil
        }

        let (tags, tagOrder) = try parseTags()
        skipLeadingNoise()

        let initialComment = parsesInitialComment ? try parseCommentList() : nil

        let (turn, color) = initialPlyState(from: tags)
        let line = try parseLine(untilVariationEnd: false, turn: turn, color: color)
        return RawPGNGame(tags: tags, tagOrder: tagOrder, initialComment: initialComment, line: line)
    }

    mutating func parseLine(
        untilVariationEnd: Bool,
        turn: UInt,
        color: PlayerColor
    ) throws -> ParsedLine {
        var currentTurn = turn
        var currentColor = color
        var head: NodeBuilder?
        var tail: NodeBuilder?
        var result: PGNOutcome?
        var leadingComments: [Substring] = []

        while true {
            skipMovetextNoise()

            guard let character = input.first else {
                if untilVariationEnd {
                    throw ReaderError.unterminatedVariation
                }
                break
            }

            if untilVariationEnd, character == ")" {
                input.removeFirst()
                break
            }

            if !untilVariationEnd, character == "[" {
                break
            }

            if let outcome = parseOutcome() {
                result = outcome
                break
            }

            if character == "(" {
                input.removeFirst()

                guard let tail else {
                    throw ReaderError.unexpectedVariation
                }

                let variation = try parseLine(
                    untilVariationEnd: true,
                    turn: tail.turn,
                    color: tail.color
                )
                if let branch = variation.head {
                    for comment in variation.leadingComments {
                        branch.annotations.absorbComment(comment, before: true)
                    }
                    tail.variants.append(branch)
                }
                continue
            }

            if character == "{" {
                let body = readCommentBody()
                if let tail {
                    tail.annotations.absorbComment(body, before: false)
                } else {
                    leadingComments.append(body)
                }
                continue
            }

            if character == ";" || character == "%" {
                skipLineComment()
                continue
            }

            if parseMoveNumber(turn: &currentTurn, color: &currentColor) {
                continue
            }

            if let codes = parseGlyphs() {
                for code in codes {
                    tail?.annotations.addNAGCode(code)
                }
                continue
            }

            if let move = try parseMove() {
                let node = NodeBuilder(
                    turn: currentTurn,
                    color: currentColor,
                    move: move
                )

                if let tail {
                    tail.next = node
                } else {
                    head = node
                }
                tail = node

                switch currentColor {
                case .white:
                    currentColor = .black
                case .black:
                    currentColor = .white
                    currentTurn += 1
                }
                continue
            }

            skipToken()
        }

        return ParsedLine(head: head, leadingComments: leadingComments, result: result)
    }

    mutating func parseTags() throws -> ([PGNTag: String], [PGNTag]) {
        var tags: [PGNTag: String] = [:]
        var order: [PGNTag] = []

        while true {
            skipLeadingNoise()

            guard input.first == "[" else {
                return (tags, order)
            }

            input.removeFirst()
            skipInlineWhitespace()

            let name = String(consume(while: { !$0.isWhitespace && $0 != "\"" && $0 != "]" }))
            skipInlineWhitespace()

            guard input.first == "\"" else {
                throw ReaderError.unterminatedTag
            }
            input.removeFirst()

            var value = ""
            var escaped = false
            var terminated = false

            while let character = input.first {
                input.removeFirst()

                if escaped {
                    if character == "\"" || character == "\\" {
                        value.append(character)
                    } else {
                        value.append("\\")
                        value.append(character)
                    }
                    escaped = false
                    continue
                }

                if character == "\\" {
                    escaped = true
                    continue
                }

                if character == "\"" {
                    terminated = true
                    break
                }

                if character == "\n" {
                    throw ReaderError.unterminatedTag
                }

                value.append(character)
            }

            guard terminated else {
                throw ReaderError.unterminatedTag
            }

            skipInlineWhitespace()

            guard input.first == "]" else {
                throw ReaderError.unterminatedTag
            }
            input.removeFirst()

            let key = PGNTag(rawValue: name) ?? .custom(name)
            if tags.updateValue(value, forKey: key) == nil {
                order.append(key)
            }
        }
    }

    mutating func parseCommentList() throws -> [PGNComment] {
        var remainder = input
        let comments = try CommentListParser().parse(&remainder)
        input = remainder
        return comments
    }

    mutating func parseMove() throws -> SANMove? {
        if let castling = parseZeroCastling() {
            return castling
        }

        guard let first = input.first, first.isLetter else {
            return nil
        }
        let token = input.prefix { !isTokenBoundary($0) }
        // Exact SAN first, then a lenient fallback for tokens such as `e8Q`.
        guard let move = FastSANParser.parse(token)
                ?? (try? SANMove(san: String(token), options: .lenient)) else {
            return nil
        }
        input = input[token.endIndex...]
        return move
    }

    /// Reads `!`, `?`, `!!`, `??`, `!?`, `?!` and `$n` glyphs.
    ///
    /// - Returns: The NAG codes, or `nil` when the input does not start with
    ///   a glyph.
    mutating func parseGlyphs() -> [Int]? {
        guard let character = input.first else { return nil }

        if character == "$" {
            let digits = input.dropFirst().prefix(while: \.isWholeNumber)
            guard !digits.isEmpty, let code = Int(digits) else { return nil }
            input.removeFirst(1 + digits.count)
            return [code]
        }

        guard character == "!" || character == "?" else { return nil }
        let symbol = input.prefix { $0 == "!" || $0 == "?" }
        input.removeFirst(symbol.count)
        switch symbol {
        case "!": return [NAG.goodMove.rawValue]
        case "?": return [NAG.poorMove.rawValue]
        case "!!": return [NAG.veryGoodMove.rawValue]
        case "??": return [NAG.veryPoorMove.rawValue]
        case "!?": return [NAG.speculativeMove.rawValue]
        case "?!": return [NAG.questionableMove.rawValue]
        default: return []
        }
    }

    /// Reads a `{...}` comment and returns its body. An unterminated comment
    /// runs to the end of the input.
    mutating func readCommentBody() -> Substring {
        input.removeFirst()
        guard let close = input.firstIndex(of: "}") else {
            let body = input
            input = input[input.endIndex...]
            return body
        }
        let body = input[..<close]
        input = input[input.index(after: close)...]
        return body
    }

    mutating func parseMoveNumber(turn: inout UInt, color: inout PlayerColor) -> Bool {
        var remainder = input
        let digits = remainder.prefix(while: \.isWholeNumber)
        guard !digits.isEmpty,
              let parsedTurn = UInt(digits) else {
            return false
        }

        remainder.removeFirst(digits.count)

        var dotCount = 0
        while remainder.first == "." {
            remainder.removeFirst()
            dotCount += 1
        }

        guard dotCount > 0 else {
            return false
        }

        turn = parsedTurn
        color = dotCount >= 3 ? .black : .white
        input = remainder
        return true
    }

    mutating func parseOutcome() -> PGNOutcome? {
        for pattern in ["1/2-1/2", "1-0", "0-1", "*"] {
            guard input.hasPrefix(pattern),
                  let outcome = PGNOutcome(rawValue: pattern) else {
                continue
            }

            let remainder = input.dropFirst(pattern.count)
            guard isTokenBoundary(remainder.first) else {
                continue
            }

            input = remainder
            return outcome
        }

        return nil
    }

    mutating func parseZeroCastling() -> SANMove? {
        let castlePrefixes = [
            ("0-0-0#", SANMove.queensideCastling(isCheck: false, isCheckMate: true)),
            ("0-0-0+", SANMove.queensideCastling(isCheck: true, isCheckMate: false)),
            ("0-0-0", SANMove.queensideCastling(isCheck: false, isCheckMate: false)),
            ("0-0#", SANMove.kingsideCastling(isCheck: false, isCheckMate: true)),
            ("0-0+", SANMove.kingsideCastling(isCheck: true, isCheckMate: false)),
            ("0-0", SANMove.kingsideCastling(isCheck: false, isCheckMate: false))
        ]

        for (prefix, move) in castlePrefixes where input.hasPrefix(prefix) {
            let remainder = input.dropFirst(prefix.count)
            guard isTokenBoundary(remainder.first) else {
                continue
            }
            input = remainder
            return move
        }

        return nil
    }

    func initialPlyState(from tags: [PGNTag: String]) -> (UInt, PlayerColor) {
        guard let fen = tags[.fen],
              let position = Position(fen: fen) else {
            return (1, .white)
        }

        return (position.fullmoves, position.playerTurn)
    }

    mutating func skipLeadingNoise() {
        if input.first == "\u{FEFF}" {
            input.removeFirst()
        }

        while true {
            let start = input.startIndex
            skipWhitespace()

            if input.first == "%" || input.first == ";" {
                skipLineComment()
                continue
            }

            if input.startIndex == start {
                return
            }
        }
    }

    mutating func skipMovetextNoise() {
        while true {
            let start = input.startIndex
            skipWhitespace()

            if input.first == ";" || input.first == "%" {
                skipLineComment()
                continue
            }

            if input.startIndex == start {
                return
            }
        }
    }

    mutating func skipWhitespace() {
        while let character = input.first, character.isWhitespace {
            input.removeFirst()
        }
    }

    mutating func skipInlineWhitespace() {
        while let character = input.first,
              character == " " || character == "\t" || character == "\r" {
            input.removeFirst()
        }
    }

    mutating func skipLineComment() {
        while let character = input.first {
            input.removeFirst()
            if character == "\n" {
                return
            }
        }
    }

    mutating func skipToken() {
        guard let character = input.first else { return }

        if isTokenBoundary(Optional(character)) {
            input.removeFirst()
            return
        }

        while let character = input.first, !isTokenBoundary(character) {
            input.removeFirst()
        }
    }

    mutating func consume(while predicate: (Character) -> Bool) -> Substring {
        let prefix = input.prefix(while: predicate)
        input.removeFirst(prefix.count)
        return prefix
    }

    func isTokenBoundary(_ character: Character?) -> Bool {
        guard let character else { return true }
        return isTokenBoundary(character)
    }

    func isTokenBoundary(_ character: Character) -> Bool {
        character.isWhitespace
            || character == "{"
            || character == "}"
            || character == "("
            || character == ")"
            || character == "!"
            || character == "?"
            || character == "$"
            || character == ";"
            || character == "."
            || character == "*"
            || character == "["
    }
}
