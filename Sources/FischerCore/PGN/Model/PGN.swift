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
    public var tags: [(PGNTag, String)]
    public var elements: [PGNElement]
}

struct PGNElement {
    let turn: UInt
    let previousWhiteCommentList: [PGNComment]?
    let whiteMove: SANMove?
    let whiteEvaluation: NAG?
    let postWhiteCommentList: [PGNComment]?
    let postWhiteVariation: [PGNElement]?
    let previousBlackCommentList: [PGNComment]?
    let blackMove: SANMove?
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

enum SANMove {
    enum FromPosition {
        case file(File)
        case rank(Rank)
        case square(Square)
    }

    enum PromotionPiece: String, CaseIterable {
        case knight = "N"
        case bishop = "B"
        case rook = "R"
        case queen = "Q"
    }

    struct SANDefaultMove {
        let piece: Piece.Kind
        let from: FromPosition?
        let isCapture: Bool
        let toSquare: Square
        let promotionTo: PromotionPiece?
        let isCheck: Bool
        let isCheckmate: Bool
    }

    case san(SANDefaultMove)
    case kingsideCastling
    case queensideCastling
}

extension SANMove.SANDefaultMove {
    init(
        kind: Piece.Kind,
        from: SANMove.FromPosition,
        isCapture: Bool?,
        toSquare: Square,
        promotion: SANMove.PromotionPiece?,
        isCheck: Bool?,
        isCheckmate: Bool?
    ) {
        self.init(
            piece: kind,
            from: from,
            isCapture: isCapture ?? false,
            toSquare: toSquare,
            promotionTo: promotion,
            isCheck: isCheck ?? false ,
            isCheckmate: isCheckmate ?? false
        )
    }


    init(
        kind: Piece.Kind,
        isCapture: Bool?,
        toSquare: Square,
        promotion: SANMove.PromotionPiece?,
        isCheck: Bool?,
        isCheckmate: Bool?
    ) {
        self.init(
            piece: kind,
            from: nil,
            isCapture: isCapture ?? false,
            toSquare: toSquare,
            promotionTo: promotion,
            isCheck: isCheck ?? false ,
            isCheckmate: isCheckmate ?? false
        )
    }
}

extension SANMove: CustomStringConvertible {
    var description: String {
        switch self {
        case .kingsideCastling:
            return "O-O"
        case .queensideCastling:
            return "O-O-O"
        case .san(let move):
            return move.description
        }
    }
}

extension SANMove.SANDefaultMove: CustomStringConvertible {
    var description: String {
        var result = ""

        switch piece {
        case .pawn:
            break
        case .knight:
            result += "N"
        case .bishop:
            result += "B"
        case .rook:
            result += "R"
        case .queen:
            result += "Q"
        case .king:
            result += "K"
        }

        if let from = from {
            switch from {
            case .file(let f):
                result += f.description
            case .rank(let r):
                result += r.description
            case .square(let s):
                result += s.description
            }
        }

        if isCapture {
            if piece == .pawn && from == nil {
                result += toSquare.file.description
            }
            result += "x"
        }

        result += toSquare.description

        if let promo = promotionTo {
            result += "=\(promo.rawValue)"
        }

        if isCheckmate {
            result += "#"
        } else if isCheck {
            result += "+"
        }

        return result
    }
}

extension PGNElement {
    init(turn: UInt, whiteMove: SANMove?, blackMove: SANMove?, postBlackVariation: [PGNElement]?, result: String?) {
        self.init(
            turn: turn,
            previousWhiteCommentList: nil,
            whiteMove: whiteMove,
            whiteEvaluation: nil,
            postWhiteCommentList: nil,
            postWhiteVariation: nil,
            previousBlackCommentList: nil,
            blackMove: blackMove,
            blackEvaluation: nil,
            postBlackCommentList: nil,
            postBlackVariation: postBlackVariation,
            result: result
        )
    }
}

extension PGNGame: CustomStringConvertible {
    var description: String {
        let taglistDescription = tags
            .map { element in
                "\(element.0.rawValue) --> \(element.1)"
            }.joined(separator: "\n")
        let movementListDescription = elements
            .map{ element in
                "\(element.turn). \(element.whiteMove?.description ?? "") \(element.blackMove?.description ?? "") \(element.result ?? "")"
            }.joined(separator: "\n")
        return """
        Game:
        \(taglistDescription)
        \(movementListDescription)
        """
    }
}
