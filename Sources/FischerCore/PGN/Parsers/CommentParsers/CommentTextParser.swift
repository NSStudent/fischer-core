//
//  CommentTextParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct CommentTextParser: Parser {
    var body: some Parser<Substring.UTF8View, [PGNComment]> {
        "{".utf8
        Prefix { $0 !=  UInt8(ascii: "}")}
            .map(.string)
            .compactMap{ [PGNComment.text($0)]}
        "}".utf8
    }
}
