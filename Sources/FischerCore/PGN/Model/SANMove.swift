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

public extension Position {
    func sanMove(from uci: String) throws -> SANMove {
        guard uci.count >= 4 else { throw FischerCoreError.illegalMove }
        
        let fromString = String(uci.prefix(2))
        let toString = String(uci.dropFirst(2).prefix(2))
        let promotionChar = uci.count == 5 ? uci.last : nil
        
        guard
            let from = Square(fromString),
            let to = Square(toString),
            let piece = board[from]
        else {
            throw FischerCoreError.illegalMove
        }
        
        // Detectar enroques
        if piece.kind == .king && from.file == .e {
            if to.file == .g {
                return .kingsideCastling
            } else if to.file == .c {
                return .queensideCastling
            }
        }

        let isCapture = board[to] != nil || (piece.kind == .pawn && to == enPassantTarget)

        let promotionTo: SANMove.PromotionPiece? = {
            guard let char = promotionChar else { return nil }
            return SANMove.PromotionPiece(rawValue: String(char).uppercased())
        }()

        let possibleDisambiguations = board.bitboard(for: piece)
            .filter { $0 != from }
            .filter {
                Move.isLegal(start: $0, end: to, piece: piece, board: board, isCapture: isCapture)
            }

        let disambiguation: SANMove.FromPosition? = {
            guard !possibleDisambiguations.isEmpty else { return nil }
            let fileUnique = !possibleDisambiguations.contains(where: { $0.file == from.file && $0 != from })
            let rankUnique = !possibleDisambiguations.contains(where: { $0.rank == from.rank && $0 != from })

            if fileUnique {
                return .file(from.file)
            } else if rankUnique {
                return .rank(from.rank)
            } else {
                return .square(from)
            }
        }()

        
        var game = try Game(position: Position(board: board))
        try game.execute(move: Move(start: from, end: to))
        let updatedBoard = game.board

        let sanDefault = SANMove.SANDefaultMove(
            piece: piece.kind,
            from: disambiguation,
            isCapture: isCapture,
            toSquare: to,
            promotionTo: promotionTo,
            isCheck: game.kingIsChecked,
            isCheckmate: game.isFinished
        )

        return .san(sanDefault)
    }
}
