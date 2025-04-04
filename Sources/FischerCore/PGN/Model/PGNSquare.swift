//
//  PGNSquare.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

struct PGNSquare {
    public var color: PGNColor
    public var square: Square
}
extension PGNSquare: CustomStringConvertible {
    var description: String {
        "\(color.rawValue)-\(square.description)"
    }
}
