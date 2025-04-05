//
//  PGNComment.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

/// Represents different types of comments and annotations in PGN (Portable Game Notation).
///
/// PGN comments can include plain text, arrows (to highlight movement or threats),
/// and highlighted squares. This enum may be extended in the future to support
/// engine evaluations and timing information.
public enum PGNComment: Equatable {
    /// A plain text comment enclosed in curly braces `{}` in PGN.
    case text(String)

    /// A list of arrows to be drawn on the board, commonly used in tools like Lichess studies.
    case arrowList([PGNArrow])

    /// A list of highlighted squares on the board.
    case squareList([PGNSquare])
//    case clockTime(String)
//    case elapsedMoveTime(String)
//    case evaluation(String)
//    case depth(String)
}

extension PGNComment: CustomStringConvertible {
    /// Returns the PGN-formatted string representation of the comment.
    ///
    /// For example: `{This is a comment}` or `{ [arrow list:[w-e2 -> e4]] }`
    public var description: String {
        switch self {
        case .text(let comment):
            return "{\(comment)}"
        case .arrowList(let comment):
            return "{ [arrow list:\(comment)] }"
        case .squareList(let comment):
            return "{ [square list:\(comment)] }"
        }
    }
}

///
/// Formats an array of PGN comments into a space-separated string representation.
///
/// Useful for printing or exporting comments from a turn or move.
extension Array where Element == PGNComment {
    var description: String {
        return self.map{$0.description}.joined(separator: " ")
    }
}
