//
//  PGN.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//

/// A container representing one or more parsed PGN chess games.
///
/// PGN files can include multiple games. This struct encapsulates
/// an array of `PGNGame` instances parsed from such a file.
///
/// - Reference: [PGN Standard Specification](https://github.com/fsmosca/PGN-Standard/blob/master/PGN-Standard.txt)
public struct PGN {
    
    /// The list of chess games parsed from a PGN source.
    public var games: [PGNGame]
}

extension PGN: CustomStringConvertible {
    
    /// A textual representation of all games in the PGN,
    /// separated by a long delimiter for readability.
    public var description: String {
        return games.map(\.description).joined(separator: "\n==============================================================================\n\n")
    }
}
