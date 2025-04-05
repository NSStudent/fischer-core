//
//  VariationParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct VariationParser: Parser {
    var body: some Parser<Substring, [PGNElement]> {
        "("
        Many {
            PGNElementBasicParser()
        } separator: {
            Whitespace()
        }
        ")"
    }
}
