//
//  PGNArrow.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

public struct PGNArrow: Equatable {
    public var color: PGNColor
    public var fromSquare: Square
    public var toSquare: Square
}

extension PGNArrow: CustomStringConvertible {
    public var description: String {
        "\(color.rawValue)-\(fromSquare.description)-\(toSquare.description)"
    }
}
