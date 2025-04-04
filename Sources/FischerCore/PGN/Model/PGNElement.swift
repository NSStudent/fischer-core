//
//  PGNElement.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//


struct PGNElement {
    let turn: UInt
    let previousWhiteCommentList: [PGNComment]?
    let whiteMove: SANMove?
    let whiteEvaluation: NAG?
    let postWhiteCommentList: [PGNComment]?
    let postWhiteVariation: [[PGNElement]]?
    let previousBlackCommentList: [PGNComment]?
    let blackMove: SANMove?
    let blackEvaluation: NAG?
    let postBlackCommentList: [PGNComment]?
    let postBlackVariation: [[PGNElement]]?
    let result: PGNOutcome?
}


extension Array where Element == [PGNElement] {
    var description: String {
        return self.map{$0.description}.joined(separator: " ")
    }
}

extension PGNElement: CustomStringConvertible {
    var description: String {
        var output = "\(turn)."
        
        if let white = whiteMove {
            output += " \(white.description)"
        } else {
            output += ".."
        }
        
        if let nag = whiteEvaluation {
            output += " $$\(nag.description)$$"
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
            output += " $$\(nag.description)$$"
        }
        
        if let postBlackCommentList {
            output += postBlackCommentList.description
        }
        if let postBlackVariation = postBlackVariation, !postBlackVariation.isEmpty {
            output += "(\(postBlackVariation.description))"
        }
        
        if let result = result {
            output += " \(result.rawValue)"
        }
        
        return output
    }
}
