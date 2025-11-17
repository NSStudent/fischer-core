//
//  EMTParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 6/11/25.
//

import Parsing

struct EMTParser: Parser {
    var body: some Parser<Substring.UTF8View, PGNComment> {
        "[%emt".utf8
        Prefix { $0 != UInt8(ascii:"]")}
            .map(.string)
            .compactMap{ PGNComment.elapsedMoveTime($0)}
        "]".utf8
    }
}

struct EvalParser: Parser {
    var body: some Parser<Substring.UTF8View, PGNComment> {
        "[%eval".utf8
        Prefix { $0 != UInt8(ascii:"]")}
            .map(.string)
            .compactMap{ PGNComment.evaluation($0)}
        "]".utf8
    }
}

struct CLKParser: Parser {
    var body: some Parser<Substring.UTF8View, PGNComment> {
        "[%clk".utf8
        Prefix { $0 != UInt8(ascii:"]")}
            .map(.string)
            .compactMap{ PGNComment.clockTime($0)}
        "]".utf8
    }
}


