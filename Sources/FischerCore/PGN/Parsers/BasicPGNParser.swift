//
//  BasicPGNParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 17/11/25.
//

import Parsing

struct BasicPGNParser: Parser {
    var body: some Parser<Substring, [BasicPGNGame]> {
        Many {
            BasicPGNGameParser()
        } separator: {
            Whitespace(1...)
        } terminator: {
            Whitespace()
        }
    }
}
