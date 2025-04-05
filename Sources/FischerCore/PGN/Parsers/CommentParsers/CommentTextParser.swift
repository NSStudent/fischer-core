//
//  CommentTextParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct CommentTextParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        "{"
        Prefix { $0 != "}"}
            .map(String.init)
            .compactMap{ [PGNComment.text($0)]}
        "}"
    }
}
