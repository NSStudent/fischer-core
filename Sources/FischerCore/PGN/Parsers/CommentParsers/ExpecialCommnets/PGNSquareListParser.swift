//
//  PGNSquareListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct PGNSquareListParser: Parser {
    var body: some Parser<Substring.UTF8View, [PGNSquare]> {
        Many {
            PGNSquareParser()
        } separator: {
            ",".utf8
        }
    }
}
