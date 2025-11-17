//
//  NoPawnAndFromParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct NoPawnAndFromParser: Parser {
    var body: some Parser<Substring.UTF8View, (Piece.Kind, SANMove.FromPosition)> {
        PieceNoPawnParser()
        FromPositionParser()
    }
}
