//
//  PGNElementBasicParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct PGNElementBasicParser: Parser {
    var body: some Parser<Substring, PGNElement> {
        Parse(PGNElement.init(turn:whiteMove:postWhiteCommentList:postWhiteVariation:blackMove:postBlackCommentList:postBlackVariation:result:)) {
            UInt.parser()
            "."

            Optionally {
                Whitespace()
                SanMoveParser()
            }
            
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
                OneOf {
                    SanMoveParser()
                    Parse {
                        Skip {
                            UInt.parser()
                        }
                        "..."
                        Whitespace()
                        SanMoveParser()
                    }
                }
            }
            
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
