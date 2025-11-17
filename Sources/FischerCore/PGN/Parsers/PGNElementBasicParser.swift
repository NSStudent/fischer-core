//
//  PGNElementBasicParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct PGNElementBasicParser: Parser {
    var body: some Parser<Substring.UTF8View, PGNElement> {
        Parse(PGNElement.init(turn:previousWhiteCommentList:whiteMove:whiteEvaluation:postWhiteCommentList:postWhiteVariation:previousBlackCommentList:blackMove:blackEvaluation:postBlackCommentList:postBlackVariation:)) {
            InitParse()
            Optionally {
                Whitespace()
                CommentListParser()
            }
            Optionally {
                Whitespace()
                OneOf {
                    SanMoveParser()
                    Parse {
                        Skip {
                            UInt.parser()
                        }
                        "...".utf8
                        Whitespace()
                        SanMoveParser()
                    }
                }
            }
            Optionally {
                Whitespace()
                NAGParser()
            }
            
            Optionally {
                Whitespace()
                CommentListParser()
            }

            Optionally {
                Whitespace()
                Many {
                    VariationParser()
                } separator: {
                    Whitespace()
                }
            }
        }
    }
}


struct InitParse: Parser {
    var body: some Parser<Substring.UTF8View,(UInt,[PGNComment]?,SANMove?,[NAG]?,[PGNComment]?,[[PGNElement]]?)> {
        OneOf {
            BlackParser()
            WhiteParser()
        }
    }
}

struct WhiteParser: Parser {
    var body: some Parser<Substring.UTF8View,(UInt,[PGNComment]?,SANMove?,[NAG]?,[PGNComment]?,[[PGNElement]]?)> {
        UInt.parser()
        ".".utf8
        Optionally {
            Whitespace()
            CommentListParser()
        }

        Optionally {
            Whitespace()
            SanMoveParser()
        }
        
        Optionally {
            Whitespace()
            NAGParser()
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
    var body: some Parser<Substring.UTF8View,(UInt,[PGNComment]?,SANMove?,[NAG]?,[PGNComment]?,[[PGNElement]]?)> {
        UInt.parser()
        "...".utf8
        Whitespace()
        Always([PGNComment]?.none)
        Always(SANMove?.none)
        Always([NAG]?.none)
        Always([PGNComment]?.none)
        Always([[PGNElement]]?.none)
    }
}
