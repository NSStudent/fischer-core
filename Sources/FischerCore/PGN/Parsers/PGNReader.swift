//
//  PGNReader.swift
//  FischerCore
//
//  Created by Codex on 22/3/26.
//

/// Reads a PGN document into an array of ``MoveTreePGN`` values.
public struct PGNReader {
    public init() {}

    public func parse(_ pgn: String) throws -> [MoveTreePGN] {
        var reader = MoveTreePGNReader(pgn)
        return try reader.readGames()
    }
}
