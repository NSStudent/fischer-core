//
//  UCIMoveValueParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 10/11/25.
//


import Parsing
public struct UCIMoveValueParser: Parser {
    public init() {}
    public var body: some Parser<Substring.UTF8View, UCIMoveValue> {
        Parse() {
            SquareParser()
            SquareParser()
            OptionalUCIPieceParser()
        }.map {UCIMoveValue(start: $0, end: $1, promotion: $2)}
    }
}
