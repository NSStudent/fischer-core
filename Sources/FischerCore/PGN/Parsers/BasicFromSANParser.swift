//
//  BasicFromSANParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct BasicFromSANParser: Parser {
    var body: some Parser<Substring, SANMove> {
        Parse(SANMove.SANDefaultMove.init(kind:from:isCapture:toSquare:promotion:isCheck:isCheckmate:)) {
            PieceParser()
            FromPositionParser()
            CaptureParser()
            SquareParser()
            PromotionParser()
            CheckParser()
            CheckMateParser()
        }.map(SANMove.san)
    }
}
