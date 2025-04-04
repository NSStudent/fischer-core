//
//  PGNArrow.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

struct PGNArrow {
    public var color: PGNColor
    public var fromSquare: Square
    public var toSquare: Square
}

extension PGNArrow: CustomStringConvertible {
    var description: String {
        "\(color.rawValue)-\(fromSquare.description)-\(toSquare.description)"
    }
}
