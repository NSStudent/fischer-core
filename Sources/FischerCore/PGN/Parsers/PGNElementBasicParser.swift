//
//  PGNElementBasicParser.swift
//  FischerCore
//
//  Created by Omar Megdadi on 3/4/25.
//

import Parsing
struct PGNElementBasicParser: Parser {
    var body: some Parser<Substring, PGNElement> {
        Parse(PGNElement.init(turn:previousWhiteCommentList:whiteMove:whiteEvaluation:postWhiteCommentList:postWhiteVariation:previousBlackCommentList:blackMove:blackEvaluation:postBlackCommentList:postBlackVariation:result:)) {
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
                        "..."
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
    var body: some Parser<Substring,(UInt,[PGNComment]?,SANMove?,NAG?,[PGNComment]?,[[PGNElement]]?)> {
        OneOf {
            BlackParser()
            WhiteParser()
        }
    }
}

struct WhiteParser: Parser {
    var body: some Parser<Substring,(UInt,[PGNComment]?,SANMove?,NAG?,[PGNComment]?,[[PGNElement]]?)> {
        UInt.parser()
        "."
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
    var body: some Parser<Substring,(UInt,[PGNComment]?,SANMove?,NAG?,[PGNComment]?,[[PGNElement]]?)> {
        UInt.parser()
        "..."
        Whitespace()
        Always([PGNComment]?.none)
        Always(SANMove?.none)
        Always(NAG?.none)
        Always([PGNComment]?.none)
        Always([[PGNElement]]?.none)
    }
}
