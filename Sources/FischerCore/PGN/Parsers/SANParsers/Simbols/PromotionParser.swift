//
//  PromotionParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct PromotionParser: Parser {
    var body: some Parser<Substring, SANMove.PromotionPiece?> {
        Optionally {
            "="
            SANMove.PromotionPiece.parser()
        }
    }
}
