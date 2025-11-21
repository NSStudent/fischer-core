//
//  PromotionPiece.swift
//  FischerCore
//
//  Created by Omar Megdadi on 14/11/25.
//


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
    
    public var uciValue: String {
        switch self {
        case .knight: return "n"
        case .bishop: return "b"
        case .rook: return "r"
        case .queen: return "q"
        }
    }
}
