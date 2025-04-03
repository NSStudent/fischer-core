//
//  TagParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct TagParser: Parser {
    var body: some Parser<Substring, [(PGNTag, String)]> {
        Many {
            Parse {
                "["
                PrefixUpTo(" \"").compactMap{PGNTag(rawValue: String($0)) }
                " \""
                Prefix{ $0 != "\""}.map(String.init)
                "\"]"
            }
        } separator: {
            "\n"
        }
    }
}
