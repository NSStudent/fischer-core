//
//  FromRankParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct FromRankParser: Parser {
    var body: some Parser<Substring, SANMove.FromPosition> {
        Prefix(1) { $0.isNumber }.map(String.init).compactMap(Int.init).compactMap(Rank.init(integerLiteral:)).compactMap {
            SANMove.FromPosition.rank($0)
        }
    }
}
