import Foundation

/// A fully-featured representation of a chess game, including move history, board state, and rules enforcement.
///
/// The `Game` struct handles:
/// - Board initialization (standard or custom FEN)
/// - Execution and validation of legal moves
/// - Castling, en passant, and promotion logic
/// - Move history tracking and undo operations
/// - Detection of game outcome and king safety
///
/// It can be used for analysis, game playback, and engine integration.
public struct Game {
    public struct GameToken {
        public var token: [String] = [String](repeating: UUID().uuidString, count: 64)
        private var piecesCount: [Int] = [Int](repeating: 0, count: 12)
        init(board: Board) {
            for square in Square.allCases {
                if let piece = board[square] {
                    piecesCount[piece.bitValue] += 1
                    token[square.rawValue] = "\(piece.fenName)\(piecesCount[piece.bitValue])"
                } else {
                    token[square.rawValue] = UUID().uuidString
                }
            }
        }
        
        mutating func update(with startSquare: Square, oldSquare: Square, capturePice: Piece? = nil) {
            (token[oldSquare.rawValue], token[startSquare.rawValue]) = (UUID().uuidString, token[oldSquare.rawValue])
        }
    }

    public enum ExecutionError: Error {

        case missingPiece(Square)
        case illegalMove(Move, PlayerColor, Board)
        case invalidPromotion(Piece.Kind)
        public var message: String {
            switch self {
            case let .missingPiece(square):
                return "Missing piece: \(square)"
            case let .illegalMove(move, color, board):
                return "Illegal move: \(move) for \(color) on \(board)"
            case let .invalidPromotion(pieceKind):
                return "Invalid promoton: \(pieceKind)"
            }
        }
    }

    public var moveHistory: [(move: Move,
                                piece: Piece,
                                capture: Piece?,
                                enPassantTarget: Square?,
                                kingAttackers: Bitboard,
                                halfmoves: UInt,
                                rights: CastlingRights)]
    private var undoHistory: [(move: Move, promotion: Piece.Kind?, kingAttackers: Bitboard)]
    public private(set) var board: Board
    public private(set) var playerTurn: PlayerColor
    public private(set) var castlingRights: CastlingRights
    public var whitePlayer: String
    public var blackPlayer: String
    public let variant: Variant
    private var attackersToKing: Bitboard
    public private(set) var fullmoves: UInt
    public private(set) var halfmoves: UInt
    public private(set) var enPassantTarget: Square?

    public var kingIsChecked: Bool {
        return attackersToKing != 0
    }

    public var kingIsDoubleChecked: Bool {
        return attackersToKing.count > 1
    }

    public var playedMoves: [Move] {
        return moveHistory.map({ $0.move })
    }

    public var moveCount: Int {
        return moveHistory.count
    }

    public var captureForLastMove: Piece? {
        return moveHistory.last?.capture
    }

    public var position: Position {
        return Position(board: board,
                        playerTurn: playerTurn,
                        castlingRights: castlingRights,
                        enPassantTarget: enPassantTarget,
                        halfmoves: halfmoves,
                        fullmoves: fullmoves)
    }

    public var isFinished: Bool {
        return availableMoves().isEmpty
    }
    
    public var token: GameToken

    /// Create a game from another.
    private init(game: Game) {
        self.moveHistory    = game.moveHistory
        self.undoHistory    = game.undoHistory
        self.board           = game.board
        self.playerTurn      = game.playerTurn
        self.castlingRights  = game.castlingRights
        self.whitePlayer     = game.whitePlayer
        self.blackPlayer     = game.blackPlayer
        self.variant         = game.variant
        self.attackersToKing = game.attackersToKing
        self.halfmoves       = game.halfmoves
        self.fullmoves       = game.fullmoves
        self.enPassantTarget = game.enPassantTarget
        self.token = GameToken(board: self.board)
    }

    public init(whitePlayer: String = "",
                blackPlayer: String = "") {
        self.moveHistory = []
        self.undoHistory = []
        self.board = Board()
        self.playerTurn = .white
        self.castlingRights = .all
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.variant = .standard
        self.attackersToKing = 0
        self.halfmoves = 0
        self.fullmoves = 1
        self.token = GameToken(board: self.board)
    }

    public init(position: Position,
                whitePlayer: String = "",
                blackPlayer: String = "",
                variant: Variant = .standard) throws {
        if let error = position.validationError() {
            throw error
        }
        self.moveHistory = []
        self.undoHistory = []
        self.board = position.board
        self.playerTurn = position.playerTurn
        self.castlingRights = position.castlingRights
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.variant = variant
        self.enPassantTarget = position.enPassantTarget
        self.attackersToKing = position.board.attackersToKing(for: position.playerTurn)
        self.halfmoves = position.halfmoves
        self.fullmoves = position.fullmoves
        self.token = GameToken(board: self.board)
    }
}

extension Game {

    /// Returns `true` if the move is legal.
    public func isLegal(move: Move) -> Bool {
        let moves = movesBitboardForPiece(at: move.start)
        return Bitboard(square: move.end).intersects(moves)
    }

    public mutating func execute(move: Move, promotion: () -> Piece.Kind) throws {
        guard isLegal(move: move) else {
            throw ExecutionError.illegalMove(move, playerTurn, board)
        }
        try execute(uncheckedMove: move, promotion: promotion)
    }

    public mutating func execute(move: Move, promotion: Piece.Kind) throws {
        try execute(move: move, promotion: { promotion })
    }

    public mutating func execute(move: Move) throws {
        try execute(move: move, promotion: .queen)
    }

    @inline(__always)
    public mutating func execute(uncheckedMove move: Move, promotion: () -> Piece.Kind) throws {
        guard let piece = board[move.start] else {
            throw ExecutionError.missingPiece(move.start)
        }
        var endPiece = piece
        var capture = board[move.end]
        var captureSquare = move.end
        let rights = castlingRights
        if piece.kind.isPawn {
            if move.end.rank == Rank(endFor: playerTurn) {
                let promotion = promotion()
                guard promotion.canPromote() else {
                    throw ExecutionError.invalidPromotion(promotion)
                }
                endPiece = Piece(kind: promotion, color: playerTurn)
            } else if move.end == enPassantTarget {
                capture = Piece(pawn: playerTurn.inverse())
                captureSquare = Square(file: move.end.file, rank: move.start.rank)
            }
        } else if piece.kind.isRook {
            switch move.start {
            case .a1: castlingRights.remove(.whiteQueenside)
            case .h1: castlingRights.remove(.whiteKingside)
            case .a8: castlingRights.remove(.blackQueenside)
            case .h8: castlingRights.remove(.blackKingside)
            default:
                break
            }
        } else if piece.kind.isKing {
            for option in castlingRights where option.color == playerTurn {
                castlingRights.remove(option)
            }
            if move.isCastle(for: playerTurn) {
                let (old, new) = move.castleSquares()
                let rook = Piece(rook: playerTurn)
                board[rook][old] = false
                board[rook][new] = true
                token.update(with: new, oldSquare: old)
            }
        }
        if let capture = capture, capture.kind.isRook {
            switch move.end {
            case .a1 where playerTurn.isBlack(): castlingRights.remove(.whiteQueenside)
            case .h1 where playerTurn.isBlack(): castlingRights.remove(.whiteKingside)
            case .a8 where playerTurn.isWhite(): castlingRights.remove(.blackQueenside)
            case .h8 where playerTurn.isWhite(): castlingRights.remove(.blackKingside)
            default:
                break
            }
        }

        moveHistory.append((move, piece, capture, enPassantTarget, attackersToKing, halfmoves, rights))
        if let capture = capture {
            board[capture][captureSquare] = false
        }
        if capture == nil && !piece.kind.isPawn {
            halfmoves += 1
        } else {
            halfmoves = 0
        }
        board[piece][move.start] = false
        board[endPiece][move.end] = true
        playerTurn.invert()
        let pieceMoved = board[move.end]!
        token.update(with: move.end, oldSquare: move.start)
        if pieceMoved.kind.isPawn && abs(move.rankChange) == 2 {
            enPassantTarget = Square(file: move.start.file, rank: pieceMoved.color.isWhite() ? 3 : 6)
        } else {
            enPassantTarget = nil
        }
        if kingIsChecked {
            attackersToKing = 0
        } else {
            attackersToKing = board.attackersToKing(for: playerTurn)
        }

        fullmoves = 1 + (UInt(moveCount) / 2)
        undoHistory = []
    }

    public func availableMoves() -> [Move] {
        return availableMoves(considerHalfmoves: true)
    }
    private func availableMoves(considerHalfmoves flag: Bool) -> [Move] {
        let moves = Square.allCases.map({ movesForPiece(at: $0, considerHalfmoves: flag) })
        return Array(moves.joined())
    }

    public func movesBitboardForPiece(at square: Square) -> Bitboard {
        return movesBitboardForPiece(at: square, considerHalfmoves: true)
    }

    private func movesForPiece(at square: Square, considerHalfmoves flag: Bool) -> [Move] {
        return movesBitboardForPiece(at: square, considerHalfmoves: flag).moves(from: square)
    }

    private func movesBitboardForPiece(at square: Square, considerHalfmoves: Bool) -> Bitboard {
       if considerHalfmoves && halfmoves >= 100 {
           return 0
       }
       guard let piece = board[square] else { return 0 }
       guard piece.color == playerTurn else { return 0 }
       if kingIsDoubleChecked {
           guard piece.kind.isKing else {
               return 0
           }
       }

       let playerBitboard = board.bitboard(for: playerTurn)
       let enemyBitboard = board.bitboard(for: playerTurn.inverse())
       let allBitboard = playerBitboard | enemyBitboard
       let emptyBitboard = ~allBitboard
       let squareBitboard = Bitboard(square: square)

       var movesBitboard: Bitboard = 0
       let attacks = square.attacks(for: piece, stoppers: allBitboard)

       if piece.kind.isPawn {
           let enPassant = enPassantTarget.map({ Bitboard(square: $0) }) ?? 0
           let pushes = squareBitboard.pawnPushes(for: playerTurn,
                                                  empty: emptyBitboard)
           let doublePushes = (squareBitboard & Bitboard(startFor: piece))
               .pawnPushes(for: playerTurn, empty: emptyBitboard)
               .pawnPushes(for: playerTurn, empty: emptyBitboard)
           movesBitboard = movesBitboard | pushes | doublePushes
           | (attacks & enemyBitboard)
               | (attacks & enPassant)
       } else {
           movesBitboard = movesBitboard | attacks & ~playerBitboard
       }

       if piece.kind.isKing && squareBitboard == Bitboard(startFor: piece) && !kingIsChecked {
           rightLoop: for right in castlingRights {
               let emptySquares = right.emptySquares
               guard right.color == playerTurn && allBitboard & emptySquares == 0 else {
                   continue
               }
               for square in emptySquares {
                   guard board.attackers(to: square, color: piece.color.inverse()).isEmpty else {
                       continue rightLoop
                   }
               }
               movesBitboard = movesBitboard | Bitboard(square: right.castleSquare)
           }
       }

       let player = playerTurn
       for moveSquare in movesBitboard {
           var copyGame = self.copy()
           try? copyGame.execute(uncheckedMove: square >>> moveSquare, promotion: { .queen })
               if copyGame.board.attackersToKing(for: player) != 0 {
                   movesBitboard[moveSquare] = false
               }

       }

       return movesBitboard
   }

    public func copy() -> Game {
        return Game(game: self)
    }

    @discardableResult
    public mutating func undoMove() -> Move? {
        guard let (move, piece, capture, enPassantTarget, attackers, halfmoves, rights) = moveHistory.popLast() else {
            return nil
        }
        var captureSquare = move.end
        var promotionKind: Piece.Kind?
        if piece.kind.isPawn {
            if move.end == enPassantTarget {
                captureSquare = Square(file: move.end.file, rank: move.start.rank)
            } else if move.end.rank == Rank(endFor: playerTurn.inverse()), let promotion = board[move.end] {
                promotionKind = promotion.kind
                board[promotion][move.end] = false
            }
        } else if piece.kind.isKing && abs(move.fileChange) == 2 {
            let (old, new) = move.castleSquares()
            let rook = Piece(rook: playerTurn.inverse())
            board[rook][old] = true
            board[rook][new] = false
            token.update(with: old, oldSquare: new)
        }
        if let capture = capture {
            board[capture][captureSquare] = true
        }
        undoHistory.append((move, promotionKind, attackers))
        board[piece][move.end] = false
        board[piece][move.start] = true
        token.update(with: move.start, oldSquare: move.end)
        playerTurn.invert()
        self.enPassantTarget = enPassantTarget
        self.attackersToKing = attackers
        self.fullmoves = 1 + (UInt(moveCount) / 2)
        self.halfmoves = halfmoves
        self.castlingRights = rights
        return move
    }
}

extension Game {
    public func sanRepresentation() -> String {
        var string = ""
        for (index, element) in moveHistory.enumerated() {
            if index % 2 == 0 {
                string += "\((index / 2 + 1) == 1 ? "" : " ")\(index / 2 + 1)."
            } else {
                string += " "
            }
            if element.piece.kind.isPawn {
                if element.capture != nil {
                    string += "\(element.move.start.file.description)x\(element.move.end)"
                } else {
                    string += "\(element.move.end)"
                }
            } else {
                if element.piece.kind.isKing && element.move.isShortCastle() {
                    string += "O-O"
                } else if element.piece.kind.isKing && element.move.isLongCastle() {
                    string += "O-O-O"
                } else {
                    if element.capture != nil {
                        string += "\(element.piece.fenName.uppercased())x\(element.move.end)"
                    } else {
                        string += "\(element.piece.fenName.uppercased())\(element.move.end)"
                    }
                }
            }
        }
        if attackersToKing != 0 {
            if self.isFinished {
                string += "#"
            } else {
                string += "+"
            }
        }
        
        return string
    }
}

extension Game {
    public init(with fen: String,
                whitePlayer: String = "",
                blackPlayer: String = "",
                variant: Variant = .standard) throws {
        guard let position = Position(fen: fen) else { throw PositionError.fenMalformed }
        self = try .init(position: position,
                     whitePlayer:  whitePlayer,
                     blackPlayer:  blackPlayer,
                     variant: variant)
    }
}

public extension Game {
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
        
        guard isLegal(move: from >>> to) else { throw FischerCoreError.illegalMove }
        
        if piece.kind == .king && from.file == .e {
            if to.file == .g {
                return .kingsideCastling
            } else if to.file == .c {
                return .queensideCastling
            }
        }

        let isCapture = self.board[to] != nil || (piece.kind == .pawn && to == enPassantTarget)

        let promotionTo: SANMove.PromotionPiece? = {
            guard let char = promotionChar else { return nil }
            return SANMove.PromotionPiece(rawValue: String(char).uppercased())
        }()

        let possibleDisambiguations = self.board.bitboard(for: piece)
            .filter { $0 != from }
            .filter {
                self.isLegal(move: $0 >>> to)
            }

        let disambiguation: SANMove.FromPosition? = {
            if isCapture && piece.kind == .pawn { return .file(from.file) }
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

        var gameAfterMove = self
        try gameAfterMove.execute(move: Move(start: from, end: to))

        let sanDefault = SANMove.SANDefaultMove(
            piece: piece.kind,
            from: disambiguation,
            isCapture: isCapture,
            toSquare: to,
            promotionTo: promotionTo,
            isCheck: gameAfterMove.kingIsChecked,
            isCheckmate: gameAfterMove.isFinished
        )
        return .san(sanDefault)
    }
    
    func sanMoveList(from uciArray: [String]) throws -> [SANMove] {
        var sanMoves: [SANMove] = []
        var currentGame = self
        for uci in uciArray {
            let sanMove = try currentGame.sanMove(from: uci)
            try currentGame.execute(move: Move.init(game: currentGame, sanMove: sanMove))
            sanMoves.append(sanMove)
        }
        return sanMoves
    }
}
