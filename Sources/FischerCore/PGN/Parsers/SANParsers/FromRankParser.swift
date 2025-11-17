//
//  FromRankParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct FromRankParser: Parser {
    var body: some Parser<Substring.UTF8View, SANMove.FromPosition> {
        Prefix(1) { String(bytes: [$0], encoding: .utf8)!.first!.isNumber }
            .map(.string)
            .compactMap(Int.init)
            .compactMap(Rank.init(integerLiteral:))
            .compactMap {
            SANMove.FromPosition.rank($0)
        }
    }
}
