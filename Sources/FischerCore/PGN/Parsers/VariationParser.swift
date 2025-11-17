//
//  VariationParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct VariationParser: Parser {
    var body: some Parser<Substring.UTF8View, [PGNElement]> {
        "(".utf8
        Whitespace()
        Many {
            PGNElementBasicParser()
        } separator: {
            Whitespace()
        }
        Whitespace()
        ")".utf8
    }
}
