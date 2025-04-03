//
//  PGNBlackVariationElementBasicParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing

struct PGNBlackElementBasicParser: Parser {
    var body: some Parser<Substring, PGNElement> {
        Parse(PGNElement.init(turn:whiteMove:postWhiteCommentList:postWhiteVariation:blackMove:postBlackCommentList:postBlackVariation:result:)) {
            UInt.parser()
            "..."
            Whitespace()
            Always(SANMove?.none)
            Always([PGNComment]?.none)
            Always([PGNElement]?.none)
            SanMoveParser()
            Optionally {
                Whitespace()
                CommentListParser()
            }

            Optionally {
                Whitespace()
                VariationParser()
            }

            Optionally {
                Whitespace()
                PGNOutcome.parser()
            }
        }
    }
}
