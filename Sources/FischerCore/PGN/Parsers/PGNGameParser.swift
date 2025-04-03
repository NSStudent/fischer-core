//
//  PGNGameParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct PGNGameParser: Parser {
    var body: some Parser<Substring, PGNGame> {
        Parse(PGNGame.init(tags:elements:)) {
            TagParser()
            "\n"
            "\n"
            Many {
                OneOf{
//                    PGNBlackElementBasicParser()
                    PGNElementBasicParser()
                }
            } separator: {
                Whitespace()
            } terminator: {
                Whitespace()
            }
        }
    }
}
