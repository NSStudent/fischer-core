//
//  PGNSquare.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

/// A square on a chessboard that includes information about the player's color.
///
/// This struct combines a `Square` (representing a position on the chessboard)
/// with a `PGNColor` (indicating the player's side, either white or black).
/// It is useful when interpreting or processing PGN data that distinguishes
/// moves or annotations based on color.
public struct PGNSquare: Equatable {
    /// The color associated with the square (white or black).
    public var color: PGNColor

    /// The square on the chessboard (e.g., e4, d5).
    public var square: Square
}
extension PGNSquare: CustomStringConvertible {
    /// A string representation of the PGNSquare in the format "color-square".
    ///
    /// For example: `"w-e4"` or `"b-d5"`.
    public var description: String {
        "\(color.rawValue)-\(square.description)"
    }
}
