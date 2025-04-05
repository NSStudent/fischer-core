//
//  PGN.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//

// Reference https://github.com/fsmosca/PGN-Standard/blob/master/PGN-Standard.txt
struct PGN {
    public var games: [PGNGame]
}

extension PGN: CustomStringConvertible {
    var description: String {
        return games.map(\.description).joined(separator: "\n==============================================================================\n\n")
    }
}
