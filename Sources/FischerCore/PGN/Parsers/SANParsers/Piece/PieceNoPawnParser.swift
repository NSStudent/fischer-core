//
//  PieceNoPawnParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct PieceNoPawnParser: Parser {
    var body: some Parser<Substring.UTF8View, Piece.Kind> {
        OneOf {
            "K".utf8.map { Piece.Kind.king }
            "Q".utf8.map { Piece.Kind.queen }
            "R".utf8.map { Piece.Kind.rook }
            "B".utf8.map { Piece.Kind.bishop }
            "N".utf8.map { Piece.Kind.knight }
        }
    }
}
