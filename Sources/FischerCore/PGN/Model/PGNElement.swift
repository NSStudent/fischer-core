//
//  PGNElement.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//  

/// Represents a full turn in a chess game, including both white and black moves,
/// associated comments, evaluations, and possible variations.
///
/// A `PGNElement` captures the state of a game at a given turn number and allows for
/// inclusion of optional annotations and nested variations, making it suitable for
/// rich PGN parsing and serialization.
public struct PGNElement {
    /// The turn number of this PGN element.
    public let turn: UInt

    /// Optional comments appearing before the white move.
    public let previousWhiteCommentList: [PGNComment]?

    /// The move played by white on this turn.
    public let whiteMove: SANMove?

    /// Optional NAG annotations evaluating the white move.
    public let whiteEvaluation: [NAG]?

    /// Optional comments appearing after the white move.
    public let postWhiteCommentList: [PGNComment]?

    /// Optional variations starting after the white move.
    public let postWhiteVariation: [[PGNElement]]?

    /// Optional comments appearing before the black move.
    public let previousBlackCommentList: [PGNComment]?

    /// The move played by black on this turn.
    public let blackMove: SANMove?

    /// Optional NAG annotations evaluating the black move.
    public let blackEvaluation: [NAG]?

    /// Optional comments appearing after the black move.
    public let postBlackCommentList: [PGNComment]?

    /// Optional variations starting after the black move.
    public let postBlackVariation: [[PGNElement]]?
}

extension Array where Element == [PGNElement] {
    /// Provides a readable description for arrays of PGN variations.
    ///
    /// This joins descriptions of each variation line with spaces.
    var description: String {
        return self.map{$0.description}.joined(separator: " ")
    }
}

extension PGNElement: CustomStringConvertible {
    /// A textual representation of the PGN element, including turn, moves, comments,
    /// NAG evaluations, and variations.
    public var description: String {
        var output = "\(turn)."
        
        if let white = whiteMove {
            output += " \(white.description)"
        } else {
            output += ".."
        }
        
        if let nag = whiteEvaluation {
            output += "\(nag.map{$0.symbol}.joined(separator: ""))"
        }
        
        if let postWhiteCommentList {
            output += postWhiteCommentList.description
        }
        if let postWhiteVariation = postWhiteVariation, !postWhiteVariation.isEmpty{
            output += "(\(postWhiteVariation.description))"
        }
        
        if let black = blackMove {
            output += " \(black.description)"
        }
        
        if let nag = blackEvaluation {
            output += "\(nag.map{$0.symbol}.joined(separator: ""))"
        }
        
        if let postBlackCommentList {
            output += postBlackCommentList.description
        }
        if let postBlackVariation = postBlackVariation, !postBlackVariation.isEmpty {
            output += "(\(postBlackVariation.description))"
        }
        
//        if let result = result {
//            output += " \(result.rawValue)"
//        }
        
        return output
    }
}

public struct PGNColumnElement {
    /// The turn number of this PGN element.
    public let turn: UInt

    /// Optional comments appearing before the move.
    public let previousCommentList: [PGNComment]?

    /// The move played by white on this turn.
    public let move: SANMove?

    /// Optional NAG annotations evaluating the move.
    public let evaluation: [NAG]?

    /// Optional comments appearing after the move.
    public let postCommentList: [PGNComment]?

    /// Optional variations starting after the move.
    public let variation: [[PGNColumnElement?]]?
    
    init(
        turn: UInt,
        previousCommentList: [PGNComment]?,
        move: SANMove?,
        evaluation: [NAG]?,
        postCommentList: [PGNComment]?,
        variation: [[PGNColumnElement?]]?
    ) {
        self.turn = turn
        self.previousCommentList = previousCommentList
        self.move = move
        self.evaluation = evaluation
        self.postCommentList = postCommentList
        self.variation = variation
    }
}

extension PGNElement: Equatable {
    public func whiteElement() -> PGNColumnElement? {
        guard self.whiteMove != nil else { return nil }
        let whiteVariationElement = self.postWhiteVariation?.map { elementArray in
            elementArray.flatMap { element in
                element.columElement()
            }
        }
        let whiteElement = PGNColumnElement(
            turn: self.turn,
            previousCommentList: self.previousWhiteCommentList,
            move: self.whiteMove,
            evaluation: self.whiteEvaluation,
            postCommentList: self.postWhiteCommentList,
            variation: whiteVariationElement
        )
        return whiteElement
    }

    public func blackElement() -> PGNColumnElement? {
        guard self.blackMove != nil else { return nil }

        let blackVariationElement = self.postBlackVariation?.map { elementArray in
            elementArray.flatMap { element in
                element.columElement()
            }
        }

        let blackElement = PGNColumnElement(
            turn: self.turn,
            previousCommentList: self.previousBlackCommentList,
            move: self.blackMove,
            evaluation: self.blackEvaluation,
            postCommentList: self.postBlackCommentList,
            variation: blackVariationElement
        )
        return blackElement
    }
    
    public func columElement() -> [PGNColumnElement?] {
        return [whiteElement(), blackElement()]
    }
}

public extension Array where Element == PGNElement {
    var asColumnElements: [PGNColumnElement?] {
        self.map { $0.columElement() }.flatMap { $0 }
    }
}

public extension PGNGame {
    var columnElements: [PGNColumnElement?] {
        self.elements.asColumnElements
    }
}
