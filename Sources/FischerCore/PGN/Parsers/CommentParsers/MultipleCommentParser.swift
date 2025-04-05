//
//  MultipleCommentParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct MultipleCommentParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        "{"
        Whitespace()
        Many {
            OneOf{
                CALParser()
                CSLParser()
            }
        } separator: {
            OneOf {
                Whitespace()
            }
        }
        Whitespace()
        "}"
    }
}
