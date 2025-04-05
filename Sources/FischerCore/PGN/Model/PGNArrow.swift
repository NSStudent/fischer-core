//
//  PGNArrow.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

/// Represents a graphical arrow annotation in a PGN comment.
///
/// These arrows are used in visual tools (e.g., Lichess studies) to indicate move suggestions,
/// threats, or analysis lines. Each arrow has a color and a direction from one square to another.
public struct PGNArrow: Equatable {
    /// The color of the arrow, typically used to convey meaning (e.g., red for threats).
    public var color: PGNColor

    /// The starting square of the arrow.
    public var fromSquare: Square

    /// The ending square of the arrow.
    public var toSquare: Square
}

extension PGNArrow: CustomStringConvertible {
    /// A string representation of the arrow in the format `Color-From-To`.
    ///
    /// For example: `R-e2-e4` represents a red arrow from e2 to e4.
    public var description: String {
        "\(color.rawValue)-\(fromSquare.description)-\(toSquare.description)"
    }
}
