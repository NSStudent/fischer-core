//
//  CommentListParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing
struct CommentListParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        Many {
            OneOf {
                MultipleCommentParser()
                CommentSquareListParser()
                CommentArrowListParser()
                CommentTextParser()
            }
        } separator: {
            Whitespace()
        } terminator: {
            Whitespace()
        }.flatMap { result in
            Always(result.flatMap{$0})
        }
    }
}
