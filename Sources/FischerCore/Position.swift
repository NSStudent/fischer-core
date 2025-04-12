//
//  Position.swift
//  FischerCore
//
//  Created by Omar Megdadi on 12/4/25.
//

public struct Position: Equatable, CustomStringConvertible {
    public var board: Board
    public var playerTurn: PlayerColor
    public var castlingRights: CastlingRights
    public var enPassantTarget: Square?
    public var halfmoves: UInt
    public var fullmoves: UInt
    
    public var description: String {
        return "Position(\(fen()))"
    }
    
    public init(board: Board = Board(),
                playerTurn: PlayerColor = .white,
                castlingRights: CastlingRights = .all,
                enPassantTarget: Square? = nil,
                halfmoves: UInt = 0,
                fullmoves: UInt = 1) {
        self.board = board
        self.playerTurn = playerTurn
        self.castlingRights = castlingRights
        self.enPassantTarget = enPassantTarget
        self.halfmoves = halfmoves
        self.fullmoves = fullmoves
    }
    
    public init?(fen: String) {
        let parts = fen.split(separator: " ").map(String.init)
        guard
            parts.count == 6,
            let board = Board(fen: parts[0]),
            parts[1].count == 1,
            let playerTurn = PlayerColor.init(string: parts[1]),
            let rights = CastlingRights(string: parts[2]),
            let halfmoves = UInt(parts[4]),
            let fullmoves = UInt(parts[5]) == 0 ? 1 : UInt(parts[5]),
            fullmoves > 0 else {
            return nil
        }
        var target: Square?
        let targetStr = parts[3]
        if targetStr.count == 2 {
            guard let square = Square(targetStr) else {
                return nil
            }
            target = square
        } else {
            guard targetStr == "-" else {
                return nil
            }
        }
        self.init(board: board,
                  playerTurn: playerTurn,
                  castlingRights: rights,
                  enPassantTarget: target,
                  halfmoves: halfmoves,
                  fullmoves: fullmoves)
    }
    
    public func fen() -> String {
        return board.fen()
        + " \(playerTurn.isWhite() ? "w" : "b") \(castlingRights.description) "
        + (enPassantTarget.map { "\($0 as Square)".lowercased() } ?? "-")
        + " \(halfmoves) \(fullmoves)"
    }
    
    public static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.playerTurn == rhs.playerTurn
        && lhs.castlingRights == rhs.castlingRights
        && lhs.halfmoves == rhs.halfmoves
        && lhs.fullmoves == rhs.fullmoves
        && lhs.enPassantTarget == rhs.enPassantTarget
        && lhs.board == rhs.board
    }
    
    internal func validationError() -> PositionError? {
        for color in PlayerColor.allCases {
            guard board.count(of: Piece(king: color)) == 1 else {
                return .wrongKingCount(color)
            }
        }
        for right in castlingRights {
            let color = right.color
            let king = Piece(king: color)
            guard board.bitboard(for: king) == Bitboard(startFor: king) else {
                return .missingKing(right)                }
            let rook = Piece(rook: color)
            let square = Square(file: right.side.isKingside ? .h : .a,
                                rank: Rank(startFor: color))
            guard board.bitboard(for: rook)[square] else {
                return .missingRook(right)
            }
        }
        if let target = enPassantTarget {
            guard target.rank == (playerTurn.isWhite() ? 6 : 3) else {
                return .wrongEnPassantTargetRank(target.rank)
            }
            if let piece = board[target] {
                return .nonEmptyEnPassantTarget(target, piece)
            }
            let pawnSquare = Square(file: target.file, rank: playerTurn.isWhite() ? 5 : 4)
            guard board[pawnSquare] == Piece(pawn: playerTurn.inverse()) else {
                return .missingEnPassantPawn(pawnSquare)
            }
            let startSquare = Square(file: target.file, rank: playerTurn.isWhite() ? 7 : 2)
            if let piece = board[startSquare] {
                return .nonEmptyEnPassantSquare(startSquare, piece)
                
            }
        }
        return nil
    }
}
