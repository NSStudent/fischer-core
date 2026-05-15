//
//  MultipleCommentParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 5/4/25.
//

import Parsing

private struct SpecialCommentParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        OneOf {
            CALParser()
            CSLParser()
            EMTParser()
            EvalParser()
            CLKParser()
        }
    }
}

private struct AdditionalSpecialCommentParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        Parse {
            Whitespace()
            SpecialCommentParser()
        }
    }
}

struct MultipleCommentParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        Parse {
            "{"
            Whitespace()
            SpecialCommentParser()
            Many {
                AdditionalSpecialCommentParser()
            }
            Optionally {
                Whitespace(1...)
                Prefix { $0 != "}" }
                    .map(String.init)
            }
            Whitespace()
            "}"
        }.map { firstComment, remainingComments, text in
            var comments = [firstComment]
            comments.append(contentsOf: remainingComments)
            if let text, !text.isEmpty {
                comments.append(.text(text))
            }
            return comments
        }
    }
}
