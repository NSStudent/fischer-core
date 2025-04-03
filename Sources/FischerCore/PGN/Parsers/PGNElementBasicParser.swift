//
//  PGNElementBasicParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct PGNElementBasicParser: Parser {
    var body: some Parser<Substring, PGNElement> {
        Parse(PGNElement.init(turn:whiteMove:blackMove:postBlackVariation:result:)) {
            UInt.parser()
            "."
            Whitespace()

            Optionally {
                SanMoveParser()
            }

            Whitespace()

            Optionally {
                SanMoveParser()
            }

            Optionally {
                Whitespace()
                VariationParser()
            }

            Optionally {
                Whitespace()
                OneOf {
                    "1-0".map{"1-0"}
                    "1/2-1/2".map{"1/2-1/2"}
                    "0-1".map{"0-1"}
                    "*".map{"*"}
                }
            }
        }
    }
}
