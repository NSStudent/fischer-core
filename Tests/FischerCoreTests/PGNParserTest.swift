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
        
        let tagParse =  Parse {
            "["
            PrefixUpTo(" \"").map{Tag(rawValue: String($0)) }
            " \""
            Prefix{ $0 != "\""}
            "\"]"
        }
        
        let tagListParse = Many {
            tagParse
        } separator: {
            "\n"
        }
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
            "Nbxd2"        // Knight from b captures on d2 (disambiguation by file)
        ]
        
        let optionalPiece = Optionally {
            OneOf {
                "K".map { Piece.Kind.king }
                "Q".map { Piece.Kind.queen }
                "R".map { Piece.Kind.rook }
                "B".map { Piece.Kind.bishop }
                "N".map { Piece.Kind.knight }
            }
        }.map { $0 ?? Piece.Kind.pawn }
        
        let squareParse = Parse {
            prefix
            Prefix(2){ Square($0) != nil }.map(String.init).compactMap { str -> Square in
                return Square(str)!
            }
        }
        
//        let optionalInitialPosition = Optionally {
//                Prefix(2) { $0.isLetter || $0.isNumber }.map(String.init).compactMap { str -> SANMove.FromPosition? in
//                    if let square = Square(str) {
//                        return SANMove.FromPosition.square(square)
//                    } else if str.count == 1 {
//                        if let file = File(rawValue: str) {
//                            return SANMove.FromPosition.file(file)
//                        } else if let rank = Rank(rawValue: str) {
//                            return SANMove.FromPosition.rank(rank)
//                        }
//                    }
//                    return nil
//                }
//            }
//        }
        
        let defaultSanParse = Parse(SANMove.SANDefaultMove.init) {
            optionalPiece
            
            "".map{ return SANMove.FromPosition.file(File.a)}

            Optionally {
                "x"
            }.map { $0 != nil }

            "".map{ return Square.a1}

            Optionally {
                Parse {
                    "="
                    OneOf {
                        "N".map { SANMove.PromotionPiece.knight }
                        "B".map { SANMove.PromotionPiece.bishop }
                        "R".map { SANMove.PromotionPiece.rook }
                        "Q".map { SANMove.PromotionPiece.queen }
                    }
                }
            }

            Optionally {
                OneOf {
                    "+".map { true }
                    "#".map { true }
                }
            }.map { $0 ?? false }

            Optionally {
                "#"
            }.map { $0 != nil }
        }
        
        
        let sanParse = OneOf {
            "O-O-O".map { SANMove.queensideCastling }
            "O-O".map { SANMove.kingsideCastling }
            defaultSanParse.map(SANMove.san)
        }
        
        let result = try sanParse.parse("Nf3")
        print(result)
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

struct OptionalFromPositionParser: Parser {
    var body: some Parser<Substring, SANMove.FromPosition?> {
        Optionally {
            OneFromPosition()
        }
    }
}

struct OneFromPosition: Parser {
    var body: some Parser<Substring, SANMove.FromPosition> {
        oneof {
            Prefix(1){ $0.isNumber }.map(String.init).compactMap { str -> SANMove.FromPosition? in
                return SANMove.FromPosition.rank(Rank(integerLiteral: Int(str)))
            }
            Prefix(1){ $0.isLetter }.map(String.init).compactMap { str -> SANMove.FromPosition? in
                return SANMove.FromPosition.file(File(string:str))
            }
            
            Prefix(2){ Square($0) != nil }.map(String.init).compactMap { str -> SANMove.FromPosition? in
                return SANMove.FromPosition.square(Square(str))
                
            }
            
        }
    }
}
