//
//  PGNColor.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//


/// Represents the colors used in PGN visual annotations such as arrows or highlighted squares.
///
/// These color codes are typically used in platforms like Lichess for study annotations.
/// The values are single-character codes:
/// - R: Red
/// - G: Green
/// - B: Blue
/// - Y: Yellow
/// - M: Magenta
/// - C: Cyan
public enum PGNColor: String, CaseIterable {
    /// Red color annotation.
    case red = "R"

    /// Green color annotation.
    case green = "G"

    /// Blue color annotation.
    case blue = "B"

    /// Yellow color annotation.
    case yellow = "Y"

    /// Magenta color annotation.
    case magenta = "M"

    /// Cyan color annotation.
    case cyan = "C"
}
