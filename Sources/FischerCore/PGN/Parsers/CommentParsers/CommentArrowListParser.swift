//
//  CommentArrowListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct CommentArrowListParser: Parser {
    var body: some Parser<Substring.UTF8View, [PGNComment]> {
        "{".utf8
        Whitespace()
        Many {
            CALParser()
        } separator: {
            Whitespace()
        }
        Whitespace()
        "}".utf8
    }
}
