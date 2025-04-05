//
//  SANMove.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

/// A representation of a move in Standard Algebraic Notation (SAN).
///
/// SANMove supports normal piece moves, captures, promotions, check/checkmate flags,
/// and also castling moves (kingside and queenside).
enum SANMove {
    /// Specifies how the origin of a move is disambiguated in SAN.
    ///
    /// When two identical pieces can move to the same square, disambiguation is needed.
    /// This enum helps represent the disambiguation component: by file, rank, or full square.
    enum FromPosition {
        case file(File)
        case rank(Rank)
        case square(Square)
    }

    /// Pieces to which a pawn may be promoted in SAN.
    ///
    /// These correspond to the letters used in SAN notation:
    /// - Q: Queen
    /// - R: Rook
    /// - B: Bishop
    /// - N: Knight
    enum PromotionPiece: String, CaseIterable {
        case knight = "N"
        case bishop = "B"
        case rook = "R"
        case queen = "Q"
    }

    /// A default SAN move representing a non-castling move in chess.
    ///
    /// Includes the piece, origin (if disambiguated), capture flag, destination,
    /// promotion (if any), and whether the move results in check or checkmate.
    struct SANDefaultMove {
        /// The type of piece making the move.
        let piece: Piece.Kind
        /// The disambiguation of the origin square, if required.
        let from: FromPosition?
        /// Whether the move is a capture.
        let isCapture: Bool
        /// The target square of the move.
        let toSquare: Square
        /// The piece to which a pawn is promoted, if any.
        let promotionTo: PromotionPiece?
        /// Whether the move results in a check.
        let isCheck: Bool
        /// Whether the move results in a checkmate.
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
    /// A string representation of the SAN move, including disambiguation,
    /// captures, promotion, and check or checkmate indicators.
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
