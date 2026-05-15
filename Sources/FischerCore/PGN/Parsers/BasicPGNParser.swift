//
//  BasicPGNParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 17/11/25.
//

import Parsing

public struct BasicPGNParser: Parser {
    public init() {}

    public var body: some Parser<Substring, [BasicPGNGame]> {
        Many {
            BasicPGNGameParser()
        } separator: {
            Whitespace(1...)
        } terminator: {
            Whitespace()
        }
    }

    public func parse(_ pgn: String) throws -> [BasicPGNGame] {
        try parse(pgn[...])
    }
}

/// Reads PGN documents into lightweight ``BasicPGNGame`` values.
public struct BasicPGNReader {
    public init() {}

    public func parse(_ pgn: String) throws -> [BasicPGNGame] {
        try BasicPGNParser().parse(pgn)
    }
}
