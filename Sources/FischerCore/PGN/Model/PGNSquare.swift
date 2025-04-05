//
//  PGNSquare.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

public struct PGNSquare: Equatable {
    public var color: PGNColor
    public var square: Square
}
extension PGNSquare: CustomStringConvertible {
    public var description: String {
        "\(color.rawValue)-\(square.description)"
    }
}
