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
            InitParse()
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
                Many {
                    Whitespace()
                    VariationParser()
                }
            }

            Optionally {
                Whitespace()
                PGNOutcome.parser()
            }
        }
    }
}


struct InitParse: Parser {
    var body: some Parser<Substring,(UInt,SANMove?,[PGNComment]?,[[PGNElement]]?)> {
        OneOf {
            BlackParser()
            WhiteParser()
        }
    }
}

struct WhiteParser: Parser {
    var body: some Parser<Substring,(UInt,SANMove?,[PGNComment]?,[[PGNElement]]?)> {
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
            Many {
                Whitespace()
                VariationParser()
            }
        }
    }
}

struct BlackParser: Parser {
    var body: some Parser<Substring,(UInt,SANMove?,[PGNComment]?,[[PGNElement]]?)> {
        UInt.parser()
        "..."
        Whitespace()
        Always(SANMove?.none)
        Always([PGNComment]?.none)
        Always([[PGNElement]]?.none)
    }
}
