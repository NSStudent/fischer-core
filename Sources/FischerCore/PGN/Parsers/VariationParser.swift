//
//  VariationParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct VariationParser: Parser {
    var body: some Parser<Substring, [PGNElement]> {
        "("
        Many {
            OneOf {
                PGNBlackElementBasicParser()
                PGNElementBasicParser()
            }
        } separator: {
            Whitespace()
        }
        ")"
    }
}


struct ComentTextParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "{"
        Prefix { $0 != "}"}
            .map(String.init)
            .compactMap{ PGNComment.text($0)}
        "}"
    }
}

struct ComentArrowListParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "{ [%cal"
        Prefix { $0 != "]"}
            .map(String.init)
            .compactMap{
                PGNComment.arrowList($0)
            }
        "] }"
    }
}

struct CommentListParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        Many {
            OneOf {
                ComentArrowListParser()
                ComentTextParser()
            }
        } separator: {
            Whitespace()
        } terminator: {
            Whitespace()
        }
    }
}

