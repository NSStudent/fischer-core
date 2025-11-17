//
//  SanMoveParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct SanMoveParser: Parser {
    var body: some Parser<Substring.UTF8View, SANMove> {
        OneOf {
            "O-O-O#".utf8.map { SANMove.queensideCastling(isCheck: false, isCheckMate: true) }
            "O-O-O+".utf8.map { SANMove.queensideCastling(isCheck: true, isCheckMate: false) }
            "O-O-O".utf8.map { SANMove.queensideCastling(isCheck: false, isCheckMate: false) }
            "O-O#".utf8.map { SANMove.kingsideCastling(isCheck: false, isCheckMate: true) }
            "O-O+".utf8.map { SANMove.kingsideCastling(isCheck: true, isCheckMate: false) }
            "O-O".utf8.map { SANMove.kingsideCastling(isCheck: false, isCheckMate: false) }
            BasicFromSANParser()
            BasicSANParser()
        }
    }
}
