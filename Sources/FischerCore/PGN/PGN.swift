//
//  PGN.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//

struct PGN {
    public var tags: [Tag: String]
    public var elements: [PGNElement]
}

enum PGNElement {
    case turn(UInt)
    case whiteMove(Move)
    case blackMove(Move)
    case evaluation(NAG)
    case variation([PGNElement])
    case comment(String)
    case arrow(from: Square, to: Square, color: HighlightColor)
    case squareHighlight(Square, color: HighlightColor)
    case tagPair(Tag, String)
}

enum HighlightColor {
    case red
}
