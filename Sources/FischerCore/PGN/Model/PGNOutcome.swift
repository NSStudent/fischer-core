//
//  PGNOutcome.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

/// Represents the outcome of a chess game in PGN (Portable Game Notation) format.
///
/// PGN outcomes follow a standard set of values to denote the result of the game:
/// - `1-0`: White wins.
/// - `0-1`: Black wins.
/// - `1/2-1/2`: Draw.
/// - `*`: Undefined or ongoing game.
///
/// Use this enum to interpret or assign result values when parsing or writing PGN data.
public enum PGNOutcome: String, CaseIterable {
    /// White wins the game.
    case win = "1-0"
    
    /// Black wins the game.
    case loss = "0-1"
    
    /// The game ends in a draw.
    case draw = "1/2-1/2"
    
    /// The game result is undefined or the game is still in progress.
    case undefined = "*"
}
