//
//  CaptureParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct CaptureParser: Parser {
    var body: some Parser<Substring.UTF8View, Bool?> {
        Optionally {
            "x".utf8.map{ true }
        }
    }
}
