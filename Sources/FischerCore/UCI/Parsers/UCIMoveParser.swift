//
//  UCIMoveParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/11/25.
//

import Parsing
struct UCIMoveParser: Parser {
    var body: some Parser<Substring.UTF8View, UCIMove> {
        OneOf {
            "0000"
                .utf8
                .map { UCIMove.nullMove }
            UCIMoveValueParser()
                .map { UCIMove.move($0) }
        }
    }
}
