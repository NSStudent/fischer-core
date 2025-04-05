//
//  CALParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct CALParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "[%cal"
        Whitespace()
        PGNArrowListParser().compactMap(PGNComment.arrowList)
        Whitespace()
        "]"
    }
}
