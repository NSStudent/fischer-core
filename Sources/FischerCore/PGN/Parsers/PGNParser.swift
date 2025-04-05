//
//  PGNParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//


import Parsing
struct PGNParser: Parser {
    var body: some Parser<Substring, PGN> {
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
