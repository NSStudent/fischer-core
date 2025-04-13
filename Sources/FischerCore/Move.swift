import Foundation

public struct Move: Hashable {
    public var start: Square
    public var end: Square
}

extension Move: Equatable {}

extension Move: CustomStringConvertible {
    public var description: String {
        return "\(start) >>> \(end)"
    }
}

extension Move {

    public var fileChange: Int {
        return end.file.rawValue - start.file.rawValue
    }

    public var rankChange: Int {
        return end.rank.rawValue - start.rank.rawValue
    }

    public var isChange: Bool {
        return start != end
    }

    public var isDiagonal: Bool {
        let fileChange = self.fileChange
        return fileChange != 0 && abs(fileChange) == abs(rankChange)
    }

    public var isHorizontal: Bool {
        return start.file != end.file && start.rank == end.rank
    }

    public var isVertical: Bool {
        return start.file == end.file && start.rank != end.rank
    }

    public var isAxial: Bool {
        return isHorizontal || isVertical
    }

    public var isLeftward: Bool {
        return end.file < start.file
    }

    public var isRightward: Bool {
        return end.file > start.file
    }

    public var isDownward: Bool {
        return end.rank < start.rank
    }

    public var isUpward: Bool {
        return end.rank > start.rank
    }

    public var isKnightJump: Bool {
        let fileChange = abs(self.fileChange)
        let rankChange = abs(self.rankChange)
        return (fileChange == 2 && rankChange == 1)
            || (rankChange == 2 && fileChange == 1)
    }

    public var fileDirection: File.Direction? {
        if self.isLeftward {
            return .left
        } else if self.isRightward {
            return .right
        } else {
            return .none
        }
    }

    public var rankDirection: Rank.Direction? {
        if self.isUpward {
            return .up
        } else if self.isDownward {
            return .down
        } else {
            return .none
        }
    }

    public init(start: Location, end: Location) {
        self.start = Square(location: start)
        self.end = Square(location: end)
    }

    public init(castle color: PlayerColor, direction: File.Direction) {
        let rank: Rank = color.isWhite() ? 1 : 8
        self = Move(start: Square(file: .e, rank: rank),
                    end: Square(file: direction == .left ? .c : .g, rank: rank))
    }

    /// Returns the castle squares for a rook.
    internal func castleSquares() -> (old: Square, new: Square) {
        let rank = start.rank
        let movedLeft = self.isLeftward
        let old = Square(file: movedLeft ? .a : .h, rank: rank)
        let new = Square(file: movedLeft ? .d : .f, rank: rank)
        return (old, new)
    }

    public func reversed() -> Move {
        return Move(start: end, end: start)
    }

    public func rotated() -> Move {
        let start = Square(file: self.start.file.opposite(),
                           rank: self.start.rank.opposite())
        let end = Square(file: self.end.file.opposite(),
                         rank: self.end.rank.opposite())
        return start >>> end
    }

    public func isCastle(for color: PlayerColor? = nil) -> Bool {
        let startRank = start.rank
        if let color = color {
            guard startRank == Rank(startFor: color) else { return false }
        } else {
            guard startRank == 1 || startRank == 8 else { return false }
        }
        let endFile = end.file
        return startRank == end.rank
            && start.file == .e
            && (endFile == .c || endFile == .g)
    }
    
    public func isLongCastle(for color: PlayerColor? = nil) -> Bool {
        let startRank = start.rank
        if let color = color {
            guard startRank == Rank(startFor: color) else { return false }
        } else {
            guard startRank == 1 || startRank == 8 else { return false }
        }
        let endFile = end.file
        return startRank == end.rank
            && start.file == .e
            && endFile == .c
    }
    
    public func isShortCastle(for color: PlayerColor? = nil) -> Bool {
        let startRank = start.rank
        if let color = color {
            guard startRank == Rank(startFor: color) else { return false }
        } else {
            guard startRank == 1 || startRank == 8 else { return false }
        }
        let endFile = end.file
        return startRank == end.rank
            && start.file == .e
            && endFile == .g
    }
}

infix operator >>>

public func >>> (start: Square, end: Square) -> Move {
    return Move(start: start, end: end)
}

public func >>> (start: Location, rhs: Location) -> Move {
    return Square(location: start) >>> Square(location: rhs)
}

extension Sequence where Iterator.Element == Square {

    public func moves(from square: Square) -> [Move] {
        return self.map({ square >>> $0 })
    }

    public func moves(to square: Square) -> [Move] {
        return self.map({ $0 >>> square })
    }

}


extension Move {
    public init(game: Game, sanMove: SANMove) throws {
        switch sanMove {
        case .san(let sanDefaultMove):
            try self.init(game: game, sanDefaultMove: sanDefaultMove)
        case .kingsideCastling:
            switch game.playerTurn {
            case .white:
                self.init(start: .e1, end: .g1)
            case .black:
                self.init(start: .e8, end: .g8)
            }
        case .queensideCastling:
            switch game.playerTurn {
            case .white:
                self.init(start: .e1, end: .c1)
            case .black:
                self.init(start: .e8, end: .c8)
            }
        }
    }
    
    init(game: Game, sanDefaultMove: SANMove.SANDefaultMove) throws {
        let piece = Piece(kind: sanDefaultMove.piece, color: game.playerTurn)
        let bitboard = game.board[piece]
        if let from = sanDefaultMove.from {
            guard let start = bitboard.first(
                where: { currentSquare in
                    switch from {
                    case .file(let file):
                        return (currentSquare.file == file) && game.isLegal(move: currentSquare >>> sanDefaultMove.toSquare)
                case .rank(let rank):
                    return (currentSquare.rank == rank) && game.isLegal(move: currentSquare >>> sanDefaultMove.toSquare)
                case .square(let sqr):
                    return sqr == currentSquare
                }
            }) else {
                    throw FischerCoreError.illegalMove
            }
            self.init(start: start, end: sanDefaultMove.toSquare)
        } else {
            guard let start = bitboard.first(where: { currentSquare in
                game.isLegal(move: currentSquare >>> sanDefaultMove.toSquare)
            }) else {
                throw FischerCoreError.illegalMove
            }
            self.init(start: start, end: sanDefaultMove.toSquare)
        }
    }
}

enum FischerCoreError: Error {
    case illegalMove
    
}
