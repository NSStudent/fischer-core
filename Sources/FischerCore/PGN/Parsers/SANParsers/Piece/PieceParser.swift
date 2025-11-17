//
//  PieceParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct PieceParser: Parser {
    var body: some Parser<Substring.UTF8View, Piece.Kind> {
        Optionally {
            OneOf {
                "K".utf8.map { Piece.Kind.king }
                "Q".utf8.map { Piece.Kind.queen }
                "R".utf8.map { Piece.Kind.rook }
                "B".utf8.map { Piece.Kind.bishop }
                "N".utf8.map { Piece.Kind.knight }
            }
        }.map { $0 ?? Piece.Kind.pawn }
    }
}
