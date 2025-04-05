//
//  CommentArrowListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct CommentArrowListParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        "{"
        Whitespace()
        Many {
            CALParser()
        } separator: {
            Whitespace()
        }
        Whitespace()
        "}"
    }
}
