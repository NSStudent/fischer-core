//
//  PGNGameParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
public struct PGNGameParser: Parser {
    public init() {}
    public var body: some Parser<Substring.UTF8View, PGNGame> {
        Parse(PGNGame.init(tags:initialComment:elements:result:)) {
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
    }
}
