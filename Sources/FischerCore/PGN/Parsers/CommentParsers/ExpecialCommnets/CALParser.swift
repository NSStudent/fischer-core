//
//  CALParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct CALParser: Parser {
    var body: some Parser<Substring.UTF8View, PGNComment> {
        "[%cal".utf8
        Whitespace()
        PGNArrowListParser().compactMap(PGNComment.arrowList)
        Whitespace()
        "]".utf8
    }
}
