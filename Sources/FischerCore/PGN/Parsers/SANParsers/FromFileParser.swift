//
//  FromFileParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct FromFileParser: Parser {
    var body: some Parser<Substring, SANMove.FromPosition> {
        Prefix(1) { $0.isLetter }.map(String.init).compactMap(File.init(string:)).compactMap {
            SANMove.FromPosition.file($0)
        }
    }
}
