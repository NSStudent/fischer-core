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
public enum SANMove: Equatable, Sendable {
    /// Specifies how the origin of a move is disambiguated in SAN.
    ///
    /// When two identical pieces can move to the same square, disambiguation is needed.
    /// This enum helps represent the disambiguation component: by file, rank, or full square.
    public enum FromPosition: Equatable, Sendable {
        case file(File)
        case rank(Rank)
        case square(Square)
    }

    /// A default SAN move representing a non-castling move in chess.
    ///
    /// Includes the piece, origin (if disambiguated), capture flag, destination,
    /// promotion (if any), and whether the move results in check or checkmate.
    public struct SANDefaultMove: Equatable, Sendable {
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

        /// Creates a non-castling SAN move.
        ///
        /// - Parameters:
        ///   - piece: The moving piece kind.
        ///   - from: The origin disambiguation, if any.
        ///   - isCapture: Whether the move captures.
        ///   - toSquare: The destination square.
        ///   - promotionTo: The promotion piece, if any.
        ///   - isCheck: Whether the move gives check.
        ///   - isCheckmate: Whether the move gives checkmate.
        public init(
            piece: Piece.Kind,
            from: SANMove.FromPosition? = nil,
            isCapture: Bool = false,
            toSquare: Square,
            promotionTo: PromotionPiece? = nil,
            isCheck: Bool = false,
            isCheckmate: Bool = false
        ) {
            self.piece = piece
            self.from = from
            self.isCapture = isCapture
            self.toSquare = toSquare
            self.promotionTo = promotionTo
            self.isCheck = isCheck
            self.isCheckmate = isCheckmate
        }
    }
    
    case san(SANDefaultMove)
    case kingsideCastling(isCheck: Bool, isCheckMate: Bool)
    case queensideCastling(isCheck: Bool, isCheckMate: Bool)
}

extension SANMove.SANDefaultMove {
    init(
        kind: Piece.Kind,
        from: SANMove.FromPosition?,
        isCapture: Bool?,
        toSquare: Square,
        promotion: PromotionPiece?,
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
        promotion: PromotionPiece?,
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
    /// The SAN text of the move in English notation, including the check
    /// (`+`) or checkmate (`#`) suffix, also for castling moves.
    public var description: String {
        description(language: .english)
    }

    /// The SAN text of the move using the piece letters of `language`.
    ///
    /// - Parameter language: The notation language for piece letters.
    /// - Returns: For example `Nf3` in English or `Cf3` in Spanish.
    public func description(language: SANNotationLanguage) -> String {
        switch self {
        case let .kingsideCastling(isCheck, isCheckMate):
            return "O-O" + Self.checkSuffix(isCheck: isCheck, isCheckmate: isCheckMate)
        case let .queensideCastling(isCheck, isCheckMate):
            return "O-O-O" + Self.checkSuffix(isCheck: isCheck, isCheckmate: isCheckMate)
        case .san(let move):
            return move.description(language: language)
        }
    }

    static func checkSuffix(isCheck: Bool, isCheckmate: Bool) -> String {
        if isCheckmate {
            return "#"
        }
        return isCheck ? "+" : ""
    }
}

public extension SANMove {
    /// Whether the move gives check (including checkmate).
    var isCheck: Bool {
        switch self {
        case let .san(move):
            return move.isCheck || move.isCheckmate
        case let .kingsideCastling(isCheck, isCheckMate), let .queensideCastling(isCheck, isCheckMate):
            return isCheck || isCheckMate
        }
    }

    /// Whether the move gives checkmate.
    var isCheckmate: Bool {
        switch self {
        case let .san(move):
            return move.isCheckmate
        case let .kingsideCastling(_, isCheckMate), let .queensideCastling(_, isCheckMate):
            return isCheckMate
        }
    }

    /// Whether the move is a castling move.
    var isCastling: Bool {
        switch self {
        case .san:
            return false
        case .kingsideCastling, .queensideCastling:
            return true
        }
    }

    /// Whether the move is marked as a capture. Castling is never a capture.
    var isCapture: Bool {
        guard case let .san(move) = self else { return false }
        return move.isCapture
    }

    /// The promotion piece written in the SAN text, if any.
    var promotion: PromotionPiece? {
        guard case let .san(move) = self else { return nil }
        return move.promotionTo
    }

    /// The same move with its check and checkmate flags replaced.
    func withCheckFlags(isCheck: Bool, isCheckmate: Bool) -> SANMove {
        switch self {
        case let .san(move):
            return .san(SANDefaultMove(
                piece: move.piece,
                from: move.from,
                isCapture: move.isCapture,
                toSquare: move.toSquare,
                promotionTo: move.promotionTo,
                isCheck: isCheck && !isCheckmate,
                isCheckmate: isCheckmate
            ))
        case .kingsideCastling:
            return .kingsideCastling(isCheck: isCheck && !isCheckmate, isCheckMate: isCheckmate)
        case .queensideCastling:
            return .queensideCastling(isCheck: isCheck && !isCheckmate, isCheckMate: isCheckmate)
        }
    }
}

extension SANMove.SANDefaultMove: CustomStringConvertible {
    /// A string representation of the SAN move, including disambiguation,
    /// captures, promotion, and check or checkmate indicators.
    public var description: String {
        description(language: .english)
    }

    /// The SAN text of the move using the piece letters of `language`.
    public func description(language: SANNotationLanguage) -> String {
        var result = language.letter(for: piece)

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
            result += "=\(language.letter(for: promo.kind))"
        }

        result += SANMove.checkSuffix(isCheck: isCheck, isCheckmate: isCheckmate)
        return result
    }
}
