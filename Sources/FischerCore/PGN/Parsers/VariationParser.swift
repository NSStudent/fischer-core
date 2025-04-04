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
            PGNElementBasicParser()
        } separator: {
            Whitespace()
        }
        ")"
    }
}


struct CommentTextParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        "{"
        Prefix { $0 != "}"}
            .map(String.init)
            .compactMap{ [PGNComment.text($0)]}
        "}"
    }
}

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

struct CALParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "[%cal"
        Whitespace()
        PGNArrowListParser().compactMap{
            PGNComment.arrowList($0)
        }
        Whitespace()
        "]"
    }
}

struct CommentArrowListParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        "{"
        Whitespace()
        Many {
            CALParser()
        } separator: {
            Whitespace()
        }
        Whitespace()
        "}"
    }
}

struct CSLParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "[%csl"
        Whitespace()
        PGNSquareListParser().compactMap{
            PGNComment.squareList($0)
        }
        Whitespace()
        "]"
    }
}

struct CommentSquareListParser: Parser {
    var body: some Parser<Substring, [PGNComment]> {
        "{"
        Whitespace()
        Many {
            CSLParser()
        } separator: {
            Whitespace()
        }
        Whitespace()
        "}"
    }
}

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

struct PGNSquareParser: Parser {
    var body: some Parser<Substring, PGNSquare> {
        Parse(PGNSquare.init(color:square:)) {
            PGNColor.parser()
            SquareParser()
        }
    }
}

struct PGNSquareListParser: Parser {
    var body: some Parser<Substring, [PGNSquare]> {
        Many {
            PGNSquareParser()
        } separator: {
            ","
        }
    }
}


struct PGNArrowParser: Parser {
    var body: some Parser<Substring, PGNArrow> {
        Parse(PGNArrow.init(color:fromSquare:toSquare:)) {
            PGNColor.parser()
            SquareParser()
            SquareParser()
        }
    }
}

struct PGNArrowListParser: Parser {
    var body: some Parser<Substring, [PGNArrow]> {
        Many {
            PGNArrowParser()
        } separator: {
            ","
        }
    }
}
