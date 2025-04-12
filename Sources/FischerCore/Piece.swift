import Foundation

public struct Piece {
    public enum Kind: Int, CaseIterable, Equatable {
        case pawn
        case knight
        case bishop
        case queen
        case rook
        case king

        public var name: String {
            switch self {
            case .pawn:
                return "pawn"
            case .knight:
                return "knight"
            case .bishop:
                return "bishop"
            case .queen:
                return "queen"
            case .rook:
                return "rook"
            case .king:
                return "king"
            }
        }
    }

    public var kind: Kind
    public var color: PlayerColor

    public var fenName: String {
        switch kind {
        case .pawn:
            return color.isWhite() ? "P" : "p"
        case .knight:
            return color.isWhite() ? "N" : "n"
        case .bishop:
            return color.isWhite() ? "B" : "b"
        case .rook:
            return color.isWhite() ? "R" : "r"
        case .queen:
            return color.isWhite() ? "Q" : "q"
        case .king:
            return color.isWhite() ? "K" : "k"
        }
    }

    public var specialCharacter: String {
        switch kind {
        case .pawn:   return color.isBlack() ? "♙" : "♟"
        case .knight: return color.isBlack()  ? "♘" : "♞"
        case .bishop: return color.isBlack()  ? "♗" : "♝"
        case .rook:   return color.isBlack()  ? "♖" : "♜"
        case .queen:  return color.isBlack()  ? "♕" : "♛"
        case .king:   return color.isBlack()  ? "♔" : "♚"
        }
    }
}

extension Piece {
    public init?(_ fenName: String) {
        guard let kind = Kind(fenName) else { return nil }
        self = Piece(kind: kind, color: fenName == fenName.uppercased() ? .white : .black)
    }

    internal init?(value: Int) {
        let newValue = value >> 1
        guard let kind = Kind(rawValue: newValue) else {
            return nil
        }
        self.init(kind: kind, color: value & 1 == 0 ? .white : .black)
    }

    public init(king color: PlayerColor) {
        self.init(kind: .king, color: color)
    }

    public init(queen color: PlayerColor) {
        self.init(kind: .queen, color: color)
    }

    public init(rook color: PlayerColor) {
        self.init(kind: .rook, color: color)
    }

    public init(bishop color: PlayerColor) {
        self.init(kind: .bishop, color: color)
    }
    
    public init(knight color: PlayerColor) {
        self.init(kind: .knight, color: color)
    }

    public init(pawn color: PlayerColor) {
        self.init(kind: .pawn, color: color)
    }

    /// The bitboard value.
    public var bitValue: Int {
        return (kind.rawValue << 1) + (color.isBlack() ? 1 : 0)
    }

    public static let all: [Piece] = {
        return [.white, .black].reduce([]) { pieces, color in
            return pieces + Piece.Kind.allCases.map({Piece(kind: $0, color: color)})
        }
    }()

    public static let whitePieces: [Piece] = Piece.all.filter({ $0.color.isWhite() })
    public static let blackPieces: [Piece] = Piece.all.filter({ $0.color.isBlack() })

    internal static let whiteNonQueens: [Piece] = whitePieces.filter({ !$0.kind.isQueen })
    internal static let blackNonQueens: [Piece] = blackPieces.filter({ !$0.kind.isQueen })

    public static func nonQueens(for color: PlayerColor) -> [Piece] {
        return color.isWhite() ? whiteNonQueens : blackNonQueens
    }

    internal static let whiteHashes: [Int] = whitePieces.map({ $0.bitValue })

    internal static let blackHashes: [Int] = blackPieces.map({ $0.bitValue })

    internal static func hashes(for color: PlayerColor) -> [Int] {
        return color.isWhite() ? whiteHashes : blackHashes
    }
}

extension Piece.Kind {
    public init?(_ fenName: String) {
        switch fenName {
        case "P", "p":
            self = .pawn
        case "N", "n":
            self = .knight
        case "B", "b":
            self = .bishop
        case "R", "r":
            self = .rook
        case "Q", "q":
            self = .queen
        case "K", "k":
            self = .king
        default:
            return nil
        }
    }

    /// The piece is `Pawn`.
    public var isPawn: Bool {
        return self == .pawn
    }
    
    /// The piece is `bishop`.
    public var isBishop: Bool {
        return self == .bishop
    }
    
    /// The piece is `knight`.
    public var isKnight: Bool {
        return self == .knight
    }

    public var isRook: Bool {
        return self == .rook
    }

    public var isQueen: Bool {
        return self == .queen
    }

    public var isKing: Bool {
        return self == .king
    }

    public func canPromote() -> Bool {
        return !(isPawn || isKing)
    }

}

extension Piece: Equatable {}
