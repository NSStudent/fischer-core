//
//  FromFileParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct FromFileParser: Parser {
    var body: some Parser<Substring.UTF8View, SANMove.FromPosition> {
        Prefix(1) { String(bytes: [$0], encoding: .utf8)!.first!.isLetter }
            .map(.string)
//            .map(String.init)
            .compactMap { string in
                return File.init(string: string)
            }.compactMap {
            SANMove.FromPosition.file($0)
        }
    }
}
