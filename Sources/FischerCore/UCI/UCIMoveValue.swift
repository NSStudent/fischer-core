//
//  UCIMoveValue.swift
//  FischerCore
//
//  Created by Omar Megdadi on 10/11/25.
//


public struct UCIMoveValue: Equatable {
    public let start: Square
    public let end: Square
    public let promotion: PromotionPiece?
}

public extension UCIMoveValue {
    func asMove() -> Move {
        .init(start: start, end: end)
    }
}

