//
//  NAGParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

import Parsing

struct NAGParser: Parser {
    var body: some Parser<Substring, NAG> {
        OneOf{
            NAGSimbolParser()
            NAGNumberParser()
        }
    }
}

struct NAGSimbolParser: Parser {
    var body: some Parser<Substring, NAG> {
        OneOf {
            Parse { "!!" }.map { NAG.veryGoodMove }
            Parse { "??" }.map { NAG.veryPoorMove }
            Parse { "!?" }.map { NAG.speculativeMove }
            Parse { "?!" }.map { NAG.questionableMove }
            Parse { "!" }.map { NAG.goodMove }
            Parse { "?" }.map { NAG.poorMove }
        }
    }
}

struct NAGNumberParser: Parser {
    var body: some Parser<Substring, NAG> {
        "$"
        NAG.parser()
    }
}
