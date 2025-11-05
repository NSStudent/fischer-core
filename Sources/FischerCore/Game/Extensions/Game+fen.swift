//
//  Game+fen.swift
//  FischerCore
//
//  Created by Omar Megdadi on 14/11/25.
//

import Foundation

extension Game {
    public init(
        with fen: String,
        whitePlayer: String = "",
        blackPlayer: String = "",
        variant: Variant = .standard
    ) throws {
        guard let position = Position(fen: fen) else { throw PositionError.fenMalformed }
        self = try .init(position: position,
                         whitePlayer:  whitePlayer,
                         blackPlayer:  blackPlayer,
                         variant: variant)
    }
}
