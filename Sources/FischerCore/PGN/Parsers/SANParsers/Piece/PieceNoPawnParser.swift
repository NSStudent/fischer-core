//
//  PieceNoPawnParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct PieceNoPawnParser: Parser {
    var body: some Parser<Substring, Piece.Kind> {
        OneOf {
            "K".map { Piece.Kind.king }
            "Q".map { Piece.Kind.queen }
            "R".map { Piece.Kind.rook }
            "B".map { Piece.Kind.bishop }
            "N".map { Piece.Kind.knight }
        }
    }
}
