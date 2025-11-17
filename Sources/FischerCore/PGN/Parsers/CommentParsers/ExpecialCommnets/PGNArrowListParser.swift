//
//  PGNArrowListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct PGNArrowListParser: Parser {
    var body: some Parser<Substring.UTF8View, [PGNArrow]> {
        Many {
            PGNArrowParser()
        } separator: {
            ",".utf8
        }
    }
}
