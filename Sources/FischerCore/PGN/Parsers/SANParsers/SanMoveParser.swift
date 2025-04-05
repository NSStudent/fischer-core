//
//  SanMoveParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct SanMoveParser: Parser {
    var body: some Parser<Substring, SANMove> {
        OneOf {
            "O-O-O".map { SANMove.queensideCastling }
            "O-O".map { SANMove.kingsideCastling }
            BasicFromSANParser()
            BasicSANParser()
        }
    }
}
