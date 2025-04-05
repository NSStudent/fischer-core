//
//  FromPositionParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct FromPositionParser: Parser {
    var body: some Parser<Substring, SANMove.FromPosition> {
        OneOf {
            SquareParser().map(SANMove.FromPosition.square)
            FromRankParser()
            FromFileParser()
        }
    }
}
