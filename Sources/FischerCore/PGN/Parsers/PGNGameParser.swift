//
//  PGNGameParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct PGNGameParser: Parser {
    var body: some Parser<Substring, PGNGame> {
        Parse(PGNGame.init(tags:initialComment:elements:)) {
            TagParser()
            "\n"
            "\n"
            Optionally {
                CommentListParser()
            }
            Many {
                PGNElementBasicParser()
            } separator: {
                Whitespace()
            } terminator: {
                Whitespace()
            }
        }
    }
}
