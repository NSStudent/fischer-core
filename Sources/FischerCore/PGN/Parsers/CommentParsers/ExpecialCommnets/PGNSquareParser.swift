//
//  PGNSquareParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct PGNSquareParser: Parser {
    var body: some Parser<Substring, PGNSquare> {
        Parse(PGNSquare.init(color:square:)) {
            PGNColor.parser()
            SquareParser()
        }
    }
}
