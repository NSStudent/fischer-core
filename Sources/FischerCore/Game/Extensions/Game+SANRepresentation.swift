//
//  Game+SANRepresentation.swift
//  FischerCore
//
//  Created by Omar Megdadi on 14/11/25.
//
import Foundation

extension Game {
    public func sanRepresentation() throws -> String {
        var auxGame = try Game(with: initialFen)
        let extraIndex = auxGame.playerTurn == .white ? 0 : 1
        var string = ""
        for (index, moveHistory) in moveHistory.enumerated() {
            let fullIndex = ((index + extraIndex) / 2)
            if index == 0 && auxGame.playerTurn == .black {
                let sanMove = try auxGame.sanMove(from: moveHistory.asUCIMove())
                string += "\(Int(auxGame.initalFullmoves) + fullIndex)... \(sanMove) "
            } else {
                if auxGame.playerTurn == .white {
                    let sanMove = try auxGame.sanMove(from: moveHistory.asUCIMove())
                    string += "\(Int(auxGame.initalFullmoves) + fullIndex).\(sanMove)"
                } else {
                    let sanMove = try auxGame.sanMove(from: moveHistory.asUCIMove())
                    string += " \(sanMove) "
                }
            }
            if let promotionPiece = moveHistory.promotionPiece {
                try auxGame.execute(move: moveHistory.move, promotion: promotionPiece)
            } else {
                try auxGame.execute(move: moveHistory.move)
            }
        }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func sanList() -> [SANMove] {
        return []
    }
}
