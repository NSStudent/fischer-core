//
//  BasicPGNGameParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 17/11/25.
//

import Parsing

struct BasicPGNGameParser: Parser {
    var body: some Parser<Substring, BasicPGNGame> {
        Parse(BasicPGNGame.init(tags:game:)) {
            TagParser()
            OneOf {
                PrefixUpTo("\n[".utf8).map(.string)
                Rest().map(.string)
            }
        }
    }
}
