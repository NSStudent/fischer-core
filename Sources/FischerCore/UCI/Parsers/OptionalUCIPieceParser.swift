//
//  OptionalUCIPieceParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/11/25.
//

import Parsing
struct OptionalUCIPieceParser: Parser {
    var body: some Parser<Substring, PromotionPiece?> {
        Optionally {
            OneOf {
                "q".map { PromotionPiece.queen }
                "r".map { PromotionPiece.rook }
                "b".map { PromotionPiece.bishop }
                "n".map { PromotionPiece.knight }
            }
        }
    }
}
