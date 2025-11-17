//
//  NAGParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

import Parsing

struct NAGParser: Parser {
    var body: some Parser<Substring.UTF8View, [NAG]> {
        Many {
            OneOf{
                NAGSimbolParser()
                NAGNumberParser()
            }
        } separator: {
            Whitespace()
        }
    }
}

struct NAGSimbolParser: Parser {
    var body: some Parser<Substring.UTF8View, NAG> {
        OneOf {
            Parse { "!!".utf8 }.map { NAG.veryGoodMove }
            Parse { "??".utf8 }.map { NAG.veryPoorMove }
            Parse { "!?".utf8 }.map { NAG.speculativeMove }
            Parse { "?!".utf8 }.map { NAG.questionableMove }
            Parse { "!".utf8 }.map { NAG.goodMove }
            Parse { "?".utf8 }.map { NAG.poorMove }
        }
    }
}

struct NAGNumberParser: Parser {
    var body: some Parser<Substring.UTF8View, NAG> {
        "$".utf8
        NAG.parser()
    }
}
