//
//  PGNGame.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

/// A parsed chess game represented in PGN (Portable Game Notation) format.
///
/// `PGNGame` encapsulates the full information of a chess game including tags, comments,
/// moves and game outcome.
public struct PGNGame {
    /// The collection of PGN tags (e.g., Event, Site, Date, etc.) describing metadata about the game.
    public var tags: [PGNTag: String]

    /// Optional initial comments that appear before the first move.
    public var initialComment: [PGNComment]?

    /// A list of elements that represent the sequential parts of a game,
    /// such as moves, comments, NAGs, or variations.
    public var elements: [PGNElement]

    /// The outcome of the game, if available.
    public var result: PGNOutcome?

    /// Returns the FEN (Forsyth-Edwards Notation) string if it's available in the tags.
    ///
    /// FEN describes a specific board position and is used to reconstruct
    /// the state of the board at the beginning of the game or any given point.
    public func fen() -> String? {
        return tags[.fen]
    }

    /// Returns the initial board position based on the FEN tag if present, or the default board.
    ///
    /// If the `FEN` tag exists and is valid, it will be used to initialize the board.
    /// Otherwise, it defaults to the standard chess starting position.
    public func initialBoard() -> Board {
        fen().flatMap(Board.init(fen:)) ?? Board()
    }
}

extension PGNGame: CustomStringConvertible {
    /// A textual representation of the game for debugging and inspection purposes.
    ///
    /// The description includes the PGN tags, initial comments, list of move elements,
    /// and the final result of the game.
    public var description: String {
        let taglistDescription = tags
            .map { element in
                "\(element.0.rawValue) --> \(element.1)"
            }.joined(separator: "\n")
        let initialCommentDescription = initialComment?.map(\.description).joined(separator: "\n")
        let movementListDescription = elements
            .map{ element in
                element.description
            }.joined(separator: "\n")
        let resultDetail = "Result: \(result?.rawValue ?? "" ) \n"
        let gameDescription = [
            taglistDescription,
            initialCommentDescription,
            movementListDescription,
            resultDetail
        ].compactMap { $0 }.joined(separator: "\n")
        return """
        Game:
        \(gameDescription)
        """
    }
}
