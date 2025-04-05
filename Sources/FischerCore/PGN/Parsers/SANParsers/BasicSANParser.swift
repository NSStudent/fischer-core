//
//  BasicSANParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct BasicSANParser: Parser {
    var body: some Parser<Substring, SANMove> {
        Parse(SANMove.SANDefaultMove.init(kind:isCapture:toSquare:promotion:isCheck:isCheckmate:)) {
            PieceParser()
            CaptureParser()
            SquareParser()
            PromotionParser()
            CheckParser()
            CheckMateParser()
        }.map(SANMove.san)
    }
}
