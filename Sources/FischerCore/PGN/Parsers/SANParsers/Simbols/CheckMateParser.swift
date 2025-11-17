//
//  CheckMateParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct CheckMateParser: Parser {
    var body: some Parser<Substring.UTF8View, Bool?> {
        Optionally {
            "#".utf8.map{ true }
        }
    }
}
