//
//  OptionalUCIPieceParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/11/25.
//

import Parsing
struct OptionalUCIPieceParser: Parser {
    var body: some Parser<Substring.UTF8View, PromotionPiece?> {
        Optionally {
            OneOf {
                "q".utf8.map { PromotionPiece.queen }
                "r".utf8.map { PromotionPiece.rook }
                "b".utf8.map { PromotionPiece.bishop }
                "n".utf8.map { PromotionPiece.knight }
            }
        }
    }
}
