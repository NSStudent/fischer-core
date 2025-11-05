//
//  EMTParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 6/11/25.
//

import Parsing

struct EMTParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "[%emt"
        Prefix { $0 != "]"}
            .map(String.init)
            .compactMap{ PGNComment.elapsedMoveTime($0)}
        "]"
    }
}

struct EvalParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "[%eval"
        Prefix { $0 != "]"}
            .map(String.init)
            .compactMap{ PGNComment.evaluation($0)}
        "]"
    }
}

struct CLKParser: Parser {
    var body: some Parser<Substring, PGNComment> {
        "[%clk"
        Prefix { $0 != "]"}
            .map(String.init)
            .compactMap{ PGNComment.clockTime($0)}
        "]"
    }
}


