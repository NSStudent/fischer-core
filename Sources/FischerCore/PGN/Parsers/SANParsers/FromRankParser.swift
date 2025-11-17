//
//  FromRankParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct FromRankParser: Parser {
    var body: some Parser<Substring.UTF8View, SANMove.FromPosition> {
        Prefix(1) {
            guard let string = String(bytes: [$0], encoding: .utf8), let char = string.first else { return false }
            return char.isNumber
        }
        .map(.string)
        .compactMap(Int.init)
        .compactMap(Rank.init(integerLiteral:))
        .compactMap {
            SANMove.FromPosition.rank($0)
        }
    }
}
