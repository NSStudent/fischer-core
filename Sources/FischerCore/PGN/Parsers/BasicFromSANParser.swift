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
            OneOf {
                NoPawnParser()
                PawnParser()
            }
            CaptureParser()
            SquareParser()
            PromotionParser()
            CheckParser()
            CheckMateParser()
        }.map(SANMove.san)
    }
}

struct NoPawnParser: Parser {
    var body: some Parser<Substring, (Piece.Kind, SANMove.FromPosition)> {
        PieceNoPawnParser()
        FromPositionParser()
    }
}

struct PawnParser: Parser {
    var body: some Parser<Substring, (Piece.Kind, SANMove.FromPosition)> {
        Always(Piece.Kind.pawn)
        FromFileParser()
    }
}

struct PieceNoPawnParser: Parser {
    var body: some Parser<Substring, Piece.Kind> {
        OneOf {
            "K".map { Piece.Kind.king }
            "Q".map { Piece.Kind.queen }
            "R".map { Piece.Kind.rook }
            "B".map { Piece.Kind.bishop }
            "N".map { Piece.Kind.knight }
        }
    }
}

