//
//  BasicPGNGame.swift
//  FischerCore
//
//  Created by Omar Megdadi on 17/11/25.
//


public struct BasicPGNGame {
    public var tags: [PGNTag: String]
    public var game: String
    
    public init(tags: [PGNTag : String], game: String) {
        self.tags = tags
        self.game = game
    }
}
