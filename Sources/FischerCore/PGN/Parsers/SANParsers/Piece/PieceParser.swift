//
//  PieceParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct PieceParser: Parser {
    var body: some Parser<Substring, Piece.Kind> {
        Optionally {
            OneOf {
                "K".map { Piece.Kind.king }
                "Q".map { Piece.Kind.queen }
                "R".map { Piece.Kind.rook }
                "B".map { Piece.Kind.bishop }
                "N".map { Piece.Kind.knight }
            }
        }.map { $0 ?? Piece.Kind.pawn }
    }
}
