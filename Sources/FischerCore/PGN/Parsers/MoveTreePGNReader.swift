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
        skipLeadingNoise()

        guard !input.isEmpty else {
            return nil
        }

        let tags = try parseTags()
        skipLeadingNoise()

        let initialComment = try parseCommentList()

        let (turn, color) = initialPlyState(from: tags)
        let line = try parseLine(untilVariationEnd: false, turn: turn, color: color)

        return MoveTreePGN(
            tags: tags,
            initialComment: initialComment,
            tree: line.head?.freeze(),
            result: line.result
        )
    }

    public mutating func readGames() throws -> [MoveTreePGN] {
        var games: [MoveTreePGN] = []
        while let game = try readGame() {
            games.append(game)
        }
        return games
    }
}

private extension MoveTreePGNReader {
    final class NodeBuilder {
        let turn: UInt
        let color: PlayerColor
        let move: SANMove
        var next: NodeBuilder?
        var variants: [NodeBuilder]

        init(
            turn: UInt,
            color: PlayerColor,
            move: SANMove,
            next: NodeBuilder? = nil,
            variants: [NodeBuilder] = []
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

    struct ParsedLine {
        let head: NodeBuilder?
        let result: PGNOutcome?
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
                    tail.variants.append(branch)
                }
                continue
            }

            if character == "{" {
                _ = try parseCommentList()
                continue
            }

            if character == ";" || character == "%" {
                skipLineComment()
                continue
            }

            if parseMoveNumber(turn: &currentTurn, color: &currentColor) {
                continue
            }

            if parseNAG() {
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

        return ParsedLine(head: head, result: result)
    }

    mutating func parseTags() throws -> [PGNTag: String] {
        var tags: [PGNTag: String] = [:]

        while true {
            skipLeadingNoise()

            guard input.first == "[" else {
                return tags
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
            tags[key] = value
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

        var remainder = input
        guard let move = try? SanMoveParser().parse(&remainder),
              isTokenBoundary(remainder.first) else {
            return nil
        }
        input = remainder
        return move
    }

    mutating func parseNAG() -> Bool {
        guard let character = input.first,
              character == "!" || character == "?" || character == "$" else {
            return false
        }

        var remainder = input
        guard (try? NAGParser().parse(&remainder)) != nil else {
            return false
        }

        guard remainder.startIndex != input.startIndex else {
            return false
        }

        input = remainder
        return true
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
            let count = input.count
            skipWhitespace()

            if input.first == "%" || input.first == ";" {
                skipLineComment()
                continue
            }

            if input.count == count {
                return
            }
        }
    }

    mutating func skipMovetextNoise() {
        while true {
            let count = input.count
            skipWhitespace()

            if input.first == ";" || input.first == "%" {
                skipLineComment()
                continue
            }

            if input.count == count {
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
