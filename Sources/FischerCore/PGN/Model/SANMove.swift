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
public enum SANMove: Equatable {
    /// Specifies how the origin of a move is disambiguated in SAN.
    ///
    /// When two identical pieces can move to the same square, disambiguation is needed.
    /// This enum helps represent the disambiguation component: by file, rank, or full square.
    public enum FromPosition: Equatable {
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
    public enum PromotionPiece: String, CaseIterable {
        case knight = "N"
        case bishop = "B"
        case rook = "R"
        case queen = "Q"
        
        public var kind: Piece.Kind {
            switch self {
            case .knight: return .knight
            case .bishop: return .bishop
            case .rook: return .rook
            case .queen: return .queen
            }
        }
    }

    /// A default SAN move representing a non-castling move in chess.
    ///
    /// Includes the piece, origin (if disambiguated), capture flag, destination,
    /// promotion (if any), and whether the move results in check or checkmate.
    public struct SANDefaultMove: Equatable {
        /// The type of piece making the move.
        public let piece: Piece.Kind
        /// The disambiguation of the origin square, if required.
        public let from: FromPosition?
        /// Whether the move is a capture.
        public let isCapture: Bool
        /// The target square of the move.
        public let toSquare: Square
        /// The piece to which a pawn is promoted, if any.
        public let promotionTo: PromotionPiece?
        /// Whether the move results in a check.
        public let isCheck: Bool
        /// Whether the move results in a checkmate.
        public let isCheckmate: Bool
    }
    
    case san(SANDefaultMove)
    case kingsideCastling
    case queensideCastling
}

extension SANMove.SANDefaultMove {
    init(
        kind: Piece.Kind,
        from: SANMove.FromPosition?,
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
    public var description: String {
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
    public var description: String {
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
