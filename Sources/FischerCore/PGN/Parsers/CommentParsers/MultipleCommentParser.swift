//
//  MultipleCommentParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

struct MultipleCommentParser: Parser {
    var body: some Parser<Substring.UTF8View, [PGNComment]> {
        "{".utf8
        Whitespace()
        Many {
            OneOf{
                CALParser()
                CSLParser()
                EMTParser()
                EvalParser()
                CLKParser()
            }
        } separator: {
            OneOf {
                Whitespace()
            }
        }
        Whitespace()
        "}".utf8
    }
}
