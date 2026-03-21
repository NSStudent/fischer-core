//
//  MoveTreePGNParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 21/3/26.
//

import Parsing

public struct MoveTreePGNParser: Parser {
    public init() {}

    public var body: some Parser<Substring, MoveTree?> {
        Parse {
            TagParser()
            Whitespace(1...)
            Optionally {
                CommentListParser()
            }
            Many {
                PGNElementBasicParser()
            } separator: {
                Whitespace()
            } terminator: {
                Whitespace()
            }
            Optionally {
                Whitespace()
                PGNOutcome.parser()
            }
            Whitespace()
        }
        .map { _, _, elements, _ in
            MoveTree.buildLine(from: elements)
        }
    }
}
