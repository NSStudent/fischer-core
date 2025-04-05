//
//  PGNSquareListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct PGNSquareListParser: Parser {
    var body: some Parser<Substring, [PGNSquare]> {
        Many {
            PGNSquareParser()
        } separator: {
            ","
        }
    }
}
