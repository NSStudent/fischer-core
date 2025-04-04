//
//  PGNComment.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

enum PGNComment {
    case text(String)
    case arrowList([PGNArrow])
    case squareList([PGNSquare])
//    case clockTime(String)
//    case elapsedMoveTime(String)
//    case evaluation(String)
//    case depth(String)
}

extension PGNComment: CustomStringConvertible {
    var description: String {
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

extension Array where Element == PGNComment {
    var description: String {
        return self.map{$0.description}.joined(separator: " ")
    }
}
