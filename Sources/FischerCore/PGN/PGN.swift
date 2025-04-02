//
//  PGN.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//


// Reference https://github.com/fsmosca/PGN-Standard/blob/master/PGN-Standard.txt

struct PGN {
    public var games: [PGNGame]
}

struct PGNGame {
    public var tags: [Tag: String]
    public var elements: [PGNElement]
}

struct PGNElement {
    let turn: UInt
    let previousWhiteCommentList: [PGNComment]?
    let whiteMove: String?
    let whiteEvaluation: NAG?
    let postWhiteCommentList: [PGNComment]?
    let postWhiteVariation: [PGNElement]?
    let previousBlackCommentList: [PGNComment]?
    let blackMove: String?
    let blackEvaluation: NAG?
    let postBlackCommentList: [PGNComment]?
    let postBlackVariation: [PGNElement]?
    let result: String?
}

enum PGNComment {
    case text(String)
//    case arrowList(String)
//    case squareList(String)
//    case clockTime(String)
//    case elapsedMoveTime(String)
//    case evaluation(String)
//    case depth(String)
}

//enum SANMove {
//    enum FromPosition {
//        case file(File)
//        case rank(Rank)
//        case square(Square)
//    }
//    
//    enum PromotionPiece {
//        case knight
//        case bishop
//        case rook
//        case queen
//    }
//    
//    struct SANDefaultMove {
//        let piece: Piece.Kind
//        let from: FromPosition?
//        let isCapture: Bool
//        let toSquare: Square
//        let promotionTo: PromotionPiece?
//        let isCheck: Bool
//        let isCheckmate: Bool
//    }
//    
//    case san(SANDefaultMove)
//    case kingsideCastling
//    case queensideCastling
//}
