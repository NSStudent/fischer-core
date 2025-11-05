//
//  UCIMoveParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/11/25.
//

import Parsing
struct UCIMoveParser: Parser {
    var body: some Parser<Substring, UCIMove> {
        OneOf {
            "0000"
                .map { UCIMove.nullMove }
            UCIMoveValueParser()
                .map { UCIMove.move($0) }
        }
    }
}
