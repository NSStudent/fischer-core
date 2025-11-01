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
            "0000".map { UCIMove.nullMove }
            Parse() {
                SquareParser()
                SquareParser()
                OptionalUCIPieceParser()
            }.map { UCIMove.move(UCIMoveValue(start: $0, end: $1, promotion: $2)) }
        }
    }
}

struct UCIMoveValue: Equatable {
    let start: Square
    let end: Square
    let promotion: Piece.Kind?
}

enum UCIMove: Equatable {
    case nullMove
    case move(UCIMoveValue)
}
