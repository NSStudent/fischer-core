//
//  PGN.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//


// Reference https://github.com/fsmosca/PGN-Standard/blob/master/PGN-Standard.txt

enum PGNColor: String, CaseIterable {
    case red = "R"
    case green = "G"
    case blue = "B"
    case yellow = "Y"
    case magenta = "M"
    case cyan = "C"
}

struct PGNArrow {
    public var color: PGNColor
    public var fromSquare: Square
    public var toSquare: Square
}

extension PGNArrow: CustomStringConvertible {
    var description: String {
        "\(color.rawValue)-\(fromSquare.description)-\(toSquare.description)"
    }
}

struct PGNSquare {
    public var color: PGNColor
    public var square: Square
}
extension PGNSquare: CustomStringConvertible {
    var description: String {
        "\(color.rawValue)-\(square.description)"
    }
}

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
    let postWhiteVariation: [[PGNElement]]?
    let previousBlackCommentList: [PGNComment]?
    let blackMove: SANMove?
    let blackEvaluation: NAG?
    let postBlackCommentList: [PGNComment]?
    let postBlackVariation: [[PGNElement]]?
    let result: PGNOutcome?
}


enum PGNComment {
    case text(String)
    case arrowList([PGNArrow])
    case squareList([PGNSquare])
//    case clockTime(String)
//    case elapsedMoveTime(String)
//    case evaluation(String)
//    case depth(String)
}

extension PGNComment: CustomStringConvertible {
    var description: String {
        switch self {
        case .text(let comment):
            return "{\(comment)}"
        case .arrowList(let comment):
            return "{ [arrow list:\(comment)] }"
        case .squareList(let comment):
            return "{ [square list:\(comment)] }"
        }
    }
}

extension Array where Element == PGNComment {
    var description: String {
        return self.map{$0.description}.joined(separator: " ")
    }
}

extension Array where Element == [PGNElement] {
    var description: String {
        return self.map{$0.description}.joined(separator: " ")
    }
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
    init(
        turn: UInt,
        whiteMove: SANMove?,
        postWhiteCommentList: [PGNComment]?,
        postWhiteVariation: [[PGNElement]]?,
        blackMove: SANMove?,
        postBlackCommentList: [PGNComment]?,
        postBlackVariation: [[PGNElement]]?,
        result: PGNOutcome?
    ) {
        self.init(
            turn: turn,
            previousWhiteCommentList: nil,
            whiteMove: whiteMove,
            whiteEvaluation: nil,
            postWhiteCommentList: postWhiteCommentList,
            postWhiteVariation: postWhiteVariation,
            previousBlackCommentList: nil,
            blackMove: blackMove,
            blackEvaluation: nil,
            postBlackCommentList: postBlackCommentList,
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
                element.description
            }.joined(separator: "\n")
        return """
        Game:
        \(taglistDescription)
        \(movementListDescription)
        """
    }
}

extension PGNElement: CustomStringConvertible {
    var description: String {
        var output = "\(turn)."

        if let white = whiteMove {
            output += " \(white.description)"
        } else {
            output += ".."
        }
        
        if let postWhiteCommentList {
            output += postWhiteCommentList.description
        }
        if let postWhiteVariation = postWhiteVariation, !postWhiteVariation.isEmpty{
            output += "(\(postWhiteVariation.description))"
        }

        if let black = blackMove {
            output += " \(black.description)"
        }
        if let postBlackCommentList {
            output += postBlackCommentList.description
        }
        if let postBlackVariation = postBlackVariation, !postBlackVariation.isEmpty {
            output += "(\(postBlackVariation.description))"
        }

        if let result = result {
            output += " \(result.rawValue)"
        }

        return output
    }
}
