//
//  OptionalUCIPieceParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/11/25.
//

import Parsing
struct OptionalUCIPieceParser: Parser {
    var body: some Parser<Substring, Piece.Kind?> {
        Optionally {
            OneOf {
                "k".map { Piece.Kind.king }
                "q".map { Piece.Kind.queen }
                "r".map { Piece.Kind.rook }
                "b".map { Piece.Kind.bishop }
                "n".map { Piece.Kind.knight }
            }
        }
    }
}
