//
//  CommentSquareListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct CommentSquareListParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        "{"
        Whitespace()
        Many {
            CSLParser()
        } separator: {
            Whitespace()
        }
        Whitespace()
        "}"
    }
}
