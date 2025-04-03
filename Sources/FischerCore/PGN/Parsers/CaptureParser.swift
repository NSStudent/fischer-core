//
//  CaptureParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct CaptureParser: Parser {
    var body: some Parser<Substring, Bool?> {
        Optionally {
            "x".map{ true }
        }
    }
}
