//
//  TagParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct TagParser: Parser {
    var body: some Parser<Substring.UTF8View, [PGNTag: String]> {
        Many {
            Parse {
                "[".utf8
                PrefixUpTo(" \"".utf8)
                    .map(.string)
                    .compactMap{PGNTag(rawValue: $0) }
                " \"".utf8
                Prefix{ $0 != UInt8(ascii:"\"")}.map(.string)
                "\"]".utf8
            }
        } separator: {
            Whitespace()
        }.map(Dictionary.init)
    }
}
