//
//  PGNArrowParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct PGNArrowParser: Parser {
    var body: some Parser<Substring, PGNArrow> {
        Parse(PGNArrow.init(color:fromSquare:toSquare:)) {
            PGNColor.parser()
            SquareParser()
            SquareParser()
        }
    }
}
