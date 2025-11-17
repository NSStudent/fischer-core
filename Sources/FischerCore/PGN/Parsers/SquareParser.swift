//
//  SquareParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct SquareParser: Parser {
    var body: some Parser<Substring.UTF8View, Square> {
        Prefix(2)
            .map(.string)
            .compactMap {
                Square.init($0)
            }
    }
}
