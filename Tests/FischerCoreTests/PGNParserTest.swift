//
//  PGNParserTest.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//
import Testing
@testable import FischerCore
import Parsing

class PGNParserTest {
    @Test("Parse tags collection")
    func parseTags() async throws {
        let tagsString = """
            [Event "F/S Return Match"]
            [Site "Belgrade, Serbia JUG"]
            [Date "1992.11.04"]
            [Round "29"]
            [White "Fischer, Robert J."]
            [Black "Spassky, Boris V."]
            [Result "1/2-1/2"]
            """
        let tagListParse = TagParser()
        let result = try tagListParse.parse(tagsString)
        print(result)
        #expect(result.count == 7)
    }

    @Test("Parse San moves")
    func parseSanMoves() async throws {
        let sanMoves: [String] = [
            "e4",          // Pawn to e4 (simple pawn move)
            "d5",          // Pawn to d5 (black reply)
            "exd5",        // Pawn capture
            "Nf3",         // Knight development
            "Nc6",         // Knight development (black)
            "Bb5",         // Bishop development
            "O-O",         // Kingside castling
            "O-O-O",       // Queenside castling
            "Rad1",        // Rook to d1 (disambiguation by file)
            "R1d2",        // Rook to d2 (disambiguation by rank)
            "Rfxd1",       // Rook capture with file disambiguation
            "Nbd2",        // Knight to d2 (disambiguation by file)
            "N1f3",        // Knight to f3 (disambiguation by rank)
            "Qxe5",        // Queen captures on e5
            "Rxe7+",       // Rook captures on e7 with check
            "Bxf7#",       // Bishop captures on f7 with checkmate
            "e8=Q",        // Pawn promotes to queen
            "bxa1=N+",     // Pawn captures on a1, promotes to knight with check
            "g1=R#",       // Pawn promotes to rook with checkmate
            "Qh5+",        // Queen gives check on h5
            "Kg1",         // King moves to g1
            "h6",          // Pawn advances to h6 (quiet move)
            "gxh6",        // Pawn captures on h6
            "a8=Q+",       // Pawn promotes to queen with check
            "R7a3",        // Rook moves to a3 (disambiguation by rank)
            "Qa5e1",       // Queen moves to e1 from a5 (full disambiguation)
            "Ndxe5",       // Knight from d captures on e5 (disambiguation by file)
            "Nbxd2",       // Knight from b captures on d2 (disambiguation by file)
        ]

        let sanParse = OneOf {
            "O-O-O".map { SANMove.queensideCastling }
            "O-O".map { SANMove.kingsideCastling }
            BasicFromSANParser()
            BasicSANParser()
        }

        //        let result = try sanParse.parse("bxa1=N+")
        //        print(result)

        let result = try sanMoves.map{ move in
            let sanMove = try sanParse.parse(move)
            return sanMove.description
        }

        #expect(sanMoves == result)
    }

    @Test("Parse a simple game")
    func parseGame() async throws {
        let input =
        """
        [Event "F/S Return Match"]
        [Site "Belgrade, Serbia JUG"]
        [Date "1992.11.04"]
        [Round "29"]
        [White "Fischer, Robert J."]
        [Black "Spassky, Boris V."]
        [Result "1/2-1/2"]

        1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3
        O-O 9. h3 Nb8 10. d4 Nbd7 11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15.
        Nb1 h6 16. Bh4 c5 17. dxe5 Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21.
        Nc4 Nxc4 22. Bxc4 Nb6 23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7
        27. Qe3 Qg5 28. Qxg5 hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33.
        f3 Bc8 34. Kf2 Bf5 35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5
        40. Rd6 Kc5 41. Ra6 Nf2 42. g4 Bd3 43. Re6 1/2-1/2
        """

        

        let parser = PGNGameParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.tags.count == 7)
        #expect(result.elements.count == 43)

        let input2 =
        """
        [Event "HKnight64's Study: ruy lopez morphy"]
        [Site "https://lichess.org/study/dnszSFnZ/qvk13wmL"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "C70"]
        [Opening "Ruy Lopez: Morphy Defense"]
        [Annotator "https://lichess.org/@/HKnight64"]
        [StudyName "HKnight64's Study"]
        [ChapterName "ruy lopez morphy"]
        [UTCDate "2025.02.10"]
        [UTCTime "11:26:38"]

        1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 *
        """
        let result2 = try parser.parse(input2)
        print(result2)
        #expect(result2.tags.count == 11)
        #expect(result2.elements.count == 4)


        let input3 =
        """
        [Event "HKnight64's Study: ruy lopez berlin"]
        [Site "https://lichess.org/study/dnszSFnZ/2Z88wfoL"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "C67"]
        [Opening "Ruy Lopez: Berlin Defense, Rio Gambit Accepted"]
        [Annotator "https://lichess.org/@/HKnight64"]
        [StudyName "HKnight64's Study"]
        [ChapterName "ruy lopez berlin"]
        [UTCDate "2025.02.10"]
        [UTCTime "11:05:29"]

        1. e4 e5 2. Nf3 Nc6 3. Bb5 Nf6 4. O-O Nxe4 5. Re1 Nf6 (5... Nd6 6. Nxe5 Be7 7. Nxc6 dxc6 8. Bf1 Bf5 9. c3 O-O 10. d4 Re8 11. Nd2 Nb5) *
        """

        let result3 = try parser.parse(input3)
        print(result3)
        #expect(result2.tags.count == 11)
        #expect(result2.elements.count == 5)
    }
}


struct PieceParser: Parser {
    var body: some Parser<Substring, Piece.Kind> {
        Optionally {
            OneOf {
                "K".map { Piece.Kind.king }
                "Q".map { Piece.Kind.queen }
                "R".map { Piece.Kind.rook }
                "B".map { Piece.Kind.bishop }
                "N".map { Piece.Kind.knight }
            }
        }.map { $0 ?? Piece.Kind.pawn }
    }
}

struct CaptureParser: Parser {
    var body: some Parser<Substring, Bool?> {
        Optionally {
            "x".map{ true }
        }
    }
}

struct SquareParser: Parser {
    var body: some Parser<Substring, Square> {
        Prefix(2)
            .map(String.init).compactMap {
                Square.init($0)
            }
    }
}

struct PromotionParser: Parser {
    var body: some Parser<Substring, SANMove.PromotionPiece?> {
        Optionally {
            "="
            SANMove.PromotionPiece.parser()
        }
    }
}

struct CheckParser: Parser {
    var body: some Parser<Substring, Bool?> {
        Optionally {
            "+".map{ true }
        }
    }
}

struct CheckMateParser: Parser {
    var body: some Parser<Substring, Bool?> {
        Optionally {
            "#".map{ true }
        }
    }
}

struct FromRankParser: Parser {
    var body: some Parser<Substring, SANMove.FromPosition> {
        Prefix(1) { $0.isNumber }.map(String.init).compactMap(Int.init).compactMap(Rank.init(integerLiteral:)).compactMap {
            SANMove.FromPosition.rank($0)
        }
    }
}

struct FromFileParser: Parser {
    var body: some Parser<Substring, SANMove.FromPosition> {
        Prefix(1) { $0.isLetter }.map(String.init).compactMap(File.init(string:)).compactMap {
            SANMove.FromPosition.file($0)
        }
    }
}
struct FromPositionParser: Parser {
    var body: some Parser<Substring, SANMove.FromPosition> {
        OneOf {
            SquareParser().map(SANMove.FromPosition.square)
            FromRankParser()
            FromFileParser()
        }
    }
}

struct BasicSANParser: Parser {
    var body: some Parser<Substring, SANMove> {
        Parse(SANMove.SANDefaultMove.init(kind:isCapture:toSquare:promotion:isCheck:isCheckmate:)) {
            PieceParser()
            CaptureParser()
            SquareParser()
            PromotionParser()
            CheckParser()
            CheckMateParser()
        }.map(SANMove.san)
    }
}

struct BasicFromSANParser: Parser {
    var body: some Parser<Substring, SANMove> {
        Parse(SANMove.SANDefaultMove.init(kind:from:isCapture:toSquare:promotion:isCheck:isCheckmate:)) {
            PieceParser()
            FromPositionParser()
            CaptureParser()
            SquareParser()
            PromotionParser()
            CheckParser()
            CheckMateParser()
        }.map(SANMove.san)
    }
}

struct TagParser: Parser {
    var body: some Parser<Substring, [(PGNTag, String)]> {
        Many {
            Parse {
                "["
                PrefixUpTo(" \"").compactMap{PGNTag(rawValue: String($0)) }
                " \""
                Prefix{ $0 != "\""}.map(String.init)
                "\"]"
            }
        } separator: {
            "\n"
        }
    }
}

struct SanMoveParser: Parser {
    var body: some Parser<Substring, SANMove> {
        OneOf {
            "O-O-O".map { SANMove.queensideCastling }
            "O-O".map { SANMove.kingsideCastling }
            BasicFromSANParser()
            BasicSANParser()
        }
    }
}

struct PGNElementBasicParser: Parser {
    var body: some Parser<Substring, PGNElement> {
        Parse(PGNElement.init(turn:whiteMove:blackMove:postBlackVariation:result:)) {
            UInt.parser()
            "."
            OneOf {
                ".."
                SpaceORBreakParser()
            }

            Optionally {
                SanMoveParser()
            }

            SpaceORBreakParser()

            Optionally {
                SanMoveParser()
            }

            Optionally {
                VariationParser()
            }

            Optionally {
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

struct VariationParser: Parser {
    var body: some Parser<Substring, [PGNElement]> {
        "("
        Many {
            PGNElementBasicParser()
        }
        ")"
    }
}
struct SpaceORBreakParser: Parser {
    var body: some Parser<Substring, Void> {
        OneOf {
            " "
            "\n"
        }
    }
}

struct PGNGameParser: Parser {
    var body: some Parser<Substring, PGNGame> {
        Parse(PGNGame.init(tags:elements:)) {
            TagParser()
            "\n"
            "\n"
            Many {
                PGNElementBasicParser()
            } separator: {
                SpaceORBreakParser()
            } terminator: {
                OneOf {
                    SpaceORBreakParser()
                    ""
                }
            }
        }
    }
}


