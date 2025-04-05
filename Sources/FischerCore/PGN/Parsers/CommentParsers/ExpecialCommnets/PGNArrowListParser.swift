//
//  PGNArrowListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct PGNArrowListParser: Parser {
    var body: some Parser<Substring, [PGNArrow]> {
        Many {
            PGNArrowParser()
        } separator: {
            ","
        }
    }
}
