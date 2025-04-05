//
//  CheckParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct CheckParser: Parser {
    var body: some Parser<Substring, Bool?> {
        Optionally {
            "+".map{ true }
        }
    }
}
