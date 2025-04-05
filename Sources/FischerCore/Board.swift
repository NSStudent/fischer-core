import Foundation

/// Represents a chessboard using bitboards for efficient position tracking and operations.
///
/// The board holds piece positions using an array of 12 bitboards—one per piece type and color.
/// It supports querying and updating squares, FEN parsing/generation, iteration over spaces,
/// and evaluation of threats, pinned pieces, and attacks.
///
/// - Note: The bitboards are indexed by `Piece.bitValue`, where `0...5` represent white pieces
/// and `6...11` black pieces.
public struct Board: Equatable {

    public enum Side {
        case kingside
        case queenside

        public var isKingside: Bool {
            return self == .kingside
        }

        public var isQueenside: Bool {
            return self == .queenside
        }
    }

    public struct Space: Equatable {
        public var piece: Piece?
        public var file: File
        public var rank: Rank

        public init(piece: Piece? = nil, square: Square) {
            self.piece = piece
            (file, rank) = square.location
        }

        public init(piece: Piece? = nil, location: Location) {
            self.piece = piece
            (file, rank) = location
        }
    }

    internal var bitboards: [Bitboard] = Array(repeating: 0, count: 12)

    public init(variant: Variant? = .standard) {
        bitboards = Array(repeating: 0, count: 12)
        if let variant = variant {
            for piece in Piece.all {
                bitboards[piece.bitValue] = Bitboard(startFor: piece)
            }
            if variant.isUpsideDown {
                for index in bitboards.indices {
                    bitboards[index].flipVertically()
                }
            }
        }
    }

    public func space(at square: Square) -> Space {
        return Space(piece: self[square], square: square)
    }

    public struct Iterator: IteratorProtocol {

        let _board: Board

        var _index: Int

        fileprivate init(_ board: Board) {
            self._board = board
            self._index = 0
        }

        /// Advances to the next space on the board and returns it.
        public mutating func next() -> Board.Space? {
            guard let square = Square(rawValue: _index) else {
                return nil
            }
            defer { _index += 1 }
            return _board.space(at: square)
        }

    }
}

extension Board: Sequence {
    public var underestimatedCount: Int {
        return 64
    }

    public func makeIterator() -> Iterator {
        return Iterator(self)
    }
}

extension Board {
    /// Gets and sets a piece at `location`.
    public subscript(location: Location) -> Piece? {
        get {
            return self[Square(location: location)]
        }
        set {
            self[Square(location: location)] = newValue
        }
    }

    public subscript(square: Square) -> Piece? {
        get {
            for index in bitboards.indices where bitboards[index][square] {
                return Piece(value: index)
            }
            return nil
        }
        set {
            for index in bitboards.indices {
                bitboards[index][square] = false
            }
            if let piece = newValue {
                bitboards[piece.bitValue][square] = true
            }
        }
    }

    internal subscript(piece: Piece) -> Bitboard {
        get {
            return bitboards[piece.bitValue]
        }
        set {
            bitboards[piece.bitValue] = newValue
        }
    }

    public func bitboard(for piece: Piece) -> Bitboard {
        return self[piece]
    }

    public func squareForKing(for color: PlayerColor) -> Square? {
        return bitboard(for: Piece(king: color)).lsbSquare
    }

    public func pinned(for color: PlayerColor) -> Bitboard {
        guard let kingSquare = squareForKing(for: color) else {
            return 0
        }
        let occupied = occupiedSpaces
        var pinned = Bitboard()
        let pieces = bitboard(for: color)
        let king = bitboard(for: Piece(king: color))
        let opRQ = bitboard(for: Piece(rook: color.inverse()))   | bitboard(for: Piece(queen: color.inverse()))
        let opBQ = bitboard(for: Piece(bishop: color.inverse())) | bitboard(for: Piece(queen: color.inverse()))
        for square in king.xrayRookAttacks(occupied: occupied, stoppers: pieces) & opRQ {
            pinned = pinned | square.between(kingSquare) & pieces
        }
        for square in king.xrayBishopAttacks(occupied: occupied, stoppers: pieces) & opBQ {
            pinned = pinned | square.between(kingSquare) & pieces
        }
        return pinned
    }

    public func attackersToKing(for color: PlayerColor) -> Bitboard {
        guard let square = squareForKing(for: color) else {
            return 0
        }
        return attackers(to: square, color: color.inverse())
    }

    public func attackers(to square: Square, color: PlayerColor) -> Bitboard {
        let all = occupiedSpaces
        let attackPieces = Piece.nonQueens(for: color)
        let playerPieces = Piece.nonQueens(for: color.inverse())
        let attacks = playerPieces.map({ piece in
            square.attacks(for: piece, stoppers: all)
        })
        let queens = (attacks[2] | attacks[3]) & self[Piece(queen: color)]
        return zip(attackPieces, attacks).reduce(queens) { $0 | (self[$1.0] & $1.1) }
    }

    public var pieces: [Piece] {
        return self.compactMap({ $0.piece })
    }

    public var whitePieces: [Piece] {
        return pieces.filter({ $0.color.isWhite() })
    }

    public var blackPieces: [Piece] {
        return pieces.filter({ $0.color.isBlack() })
    }

    public var occupiedSpaces: Bitboard {
        return bitboards.reduce(0, |)
    }

    /// A bitboard for the empty spaces of `self`.
    public var emptySpaces: Bitboard {
        return ~occupiedSpaces
    }

    public func count(of piece: Piece) -> Int {
        return bitboard(for: piece).count
    }

}

extension Board {
    /// Initializes a `Board` instance from a FEN (Forsyth–Edwards Notation) string.
    ///
    /// This parses the piece placement section of the FEN string (first field),
    /// and sets up the board accordingly. Returns `nil` if the format is invalid.
    ///
    /// - Parameter fen: A FEN string describing a board position.
    /// - Returns: A board with pieces placed according to the FEN, or `nil` if the FEN is invalid.
    public init?(fen: String) {

        func pieces(for string: String) -> [Piece?]? {
            var pieces: [Piece?] = []
            for char in string {
                guard pieces.count < 8 else {
                    return nil
                }
                if let piece = Piece(String(char)) {
                    pieces.append(piece)
                } else if let num = Int(String(char)) {
                    guard 1...8 ~= num else { return nil }
                    pieces += Array(repeating: nil, count: num)
                } else {
                    return nil
                }
            }
            return pieces
        }
        let fenParts = fen.components(separatedBy: " ")
        guard let piecesPart = fenParts.first else { return nil }
        let rankSections = piecesPart.split(separator: "/")
        guard rankSections.count == 8 else {
            return nil
        }
        var board = Board()
        let reversed = Rank.allCases.reversed()
        for (rank, part) in zip(reversed, rankSections) {
            guard let pieces = pieces(for: String(part)) else {
                return nil
            }
            for (file, piece) in zip(File.allCases, pieces) {
                board[(file, rank)] = piece
            }
        }
        self = board
    }

    public func fen() -> String {
        func fen(forRank rank: Rank) -> String {
            var fen = ""
            var accumulator = 0
            for space in spaces(at: rank) {
                if let piece = space.piece {
                    if accumulator > 0 {
                        fen += String(accumulator)
                        accumulator = 0
                    }
                    fen += piece.fenName
                } else {
                    accumulator += 1
                    if space.file == .h {
                        fen += String(accumulator)
                    }
                }
            }
            return fen
        }
        return Rank.allCases.reversed().map(fen).joined(separator: "/")

    }

    public func spaces(at rank: Rank) -> [Space] {
        return File.allCases.map { space(at: ($0, rank)) }
    }

    public func space(at location: Location) -> Space {
        return Space(piece: self[location], location: location)
    }

    public func bitboard(for color: PlayerColor) -> Bitboard {
        return Piece.hashes(for: color).reduce(0) { $0 | bitboards[$1] }
    }

    public func ascii() -> String {
        let edge = "  +-----------------+\n"
        var result = edge
        let reversed = Rank.allCases.reversed()
        for rank in reversed {
            let strings = File.allCases.map({ file in "\(self[(file, rank)]?.specialCharacter ?? ".")" })
            let str = strings.joined(separator: " ")
            result += "\(rank.description) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h"
        return result
    }
}

extension Board: CustomStringConvertible {
    public var description: String {
        return fen()
    }
}
