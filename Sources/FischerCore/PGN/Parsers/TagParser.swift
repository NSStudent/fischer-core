//
//  TagParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct TagParser: Parser {
    func parse(_ input: inout Substring) throws -> [PGNTag: String] {
        var tags: [PGNTag: String] = [:]

        while input.first == "[" {
            let (tag, value) = try parseTag(&input)
            tags[tag] = value

            var nextTagInput = input
            nextTagInput.consumeWhitespace()
            guard nextTagInput.first == "[" else {
                break
            }
            input = nextTagInput
        }

        return tags
    }

    private func parseTag(_ input: inout Substring) throws -> (PGNTag, String) {
        guard input.first == "[" else {
            throw TagParserError.unterminatedTag
        }
        input.removeFirst()
        input.consumeInlineWhitespace()

        let rawName = input.consume { character in
            character != "\"" && character != "]"
        }
        let name = rawName.trimmingInlineWhitespace()
        guard !name.isEmpty else {
            throw TagParserError.unterminatedTag
        }

        guard input.first == "\"" else {
            throw TagParserError.unterminatedTag
        }
        input.removeFirst()

        let value = try parseTagValue(&input)

        input.consumeInlineWhitespace()
        guard input.first == "]" else {
            throw TagParserError.unterminatedTag
        }
        input.removeFirst()

        return (PGNTag(rawValue: name) ?? .custom(name), value)
    }

    private func parseTagValue(_ input: inout Substring) throws -> String {
        var value = ""
        var escaped = false

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
                return value
            }

            if character == "\n" {
                throw TagParserError.unterminatedTag
            }

            value.append(character)
        }

        throw TagParserError.unterminatedTag
    }
}

private enum TagParserError: Error, Equatable {
    case unterminatedTag
}

private extension Substring {
    mutating func consume(while shouldConsume: (Character) -> Bool) -> Substring {
        let prefix = prefix(while: shouldConsume)
        removeFirst(prefix.count)
        return prefix
    }

    mutating func consumeInlineWhitespace() {
        _ = consume { character in
            character == " " || character == "\t"
        }
    }

    mutating func consumeWhitespace() {
        _ = consume { character in
            character.isWhitespace
        }
    }

    func trimmingInlineWhitespace() -> String {
        var substring = self
        while substring.first == " " || substring.first == "\t" {
            substring.removeFirst()
        }
        while substring.last == " " || substring.last == "\t" {
            substring.removeLast()
        }
        return String(substring)
    }
}
