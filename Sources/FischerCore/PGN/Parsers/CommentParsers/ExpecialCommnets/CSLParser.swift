//
//  CSLParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct CSLParser: Parser {
    var body: some Parser<Substring.UTF8View, PGNComment> {
        "[%csl".utf8
        Whitespace()
        PGNSquareListParser().compactMap{
            PGNComment.squareList($0)
        }
        Whitespace()
        "]".utf8
    }
}
