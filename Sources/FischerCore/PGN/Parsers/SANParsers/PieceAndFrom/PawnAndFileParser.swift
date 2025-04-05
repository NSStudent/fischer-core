//
//  PawnAndFileParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct PawnAndFileParser: Parser {
    var body: some Parser<Substring, (Piece.Kind, SANMove.FromPosition)> {
        Always(Piece.Kind.pawn)
        FromFileParser()
    }
}
