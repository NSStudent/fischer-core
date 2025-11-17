//
//  PGNParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//


import Parsing
struct PGNParser: Parser {
    var body: some Parser<Substring.UTF8View, PGN> {
        Many {
            PGNGameParser()
        } separator: {
            Whitespace()
        } terminator: {
            Whitespace()
        }
        .map(PGN.init)
    }
}

struct BasicPGNParser: Parser {
    var body: some Parser<Substring.UTF8View, [String]> {
        Many {
            BasicPGNGameParser()
        } separator: {
            Whitespace(1...)
        } terminator: {
            Whitespace()
        }
    }
}

struct BasicPGNGameParser: Parser {
    var body: some Parser<Substring.UTF8View, String> {
        OneOf {
            PrefixUpTo("\n[Event ".utf8).map(.string)
            Rest().map(.string)
        }
    }
}
