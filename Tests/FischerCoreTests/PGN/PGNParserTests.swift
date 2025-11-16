//
//  PGNParserTests.swift
//  FischerCore
//
//  Created by Omar Megdadi on 16/11/25.
//
import Testing
@testable import FischerCore
import Parsing

class PGNParserTests {
    
    @Test("Lichess studio parser")
    func lichessStudioPGNParser() async throws {
        let input =
        """
        [Event "Square Control: Chapter 1"]
        [Site "https://lichess.org/study/jIEHYquv/Y8W0R708"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/jk_182"]
        [StudyName "Square Control"]
        [ChapterName "Chapter 1"]
        [FEN "r5k1/pppr1ppp/8/8/8/8/PPP1RPPP/4R1K1 w - - 0 1"]
        [SetUp "1"]
        [UTCDate "2025.04.04"]
        [UTCTime "19:57:03"]
        
                 1. e4 $0 e5 $1*
        
        
        [Event "Square Control: N. Kralin, O. Pervakov, 1998 (end of study)"]
        [Site "https://lichess.org/study/jIEHYquv/d7sN1Gfa"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/jk_182"]
        [StudyName "Square Control"]
        [ChapterName "N. Kralin, O. Pervakov, 1998 (end of study)"]
        [FEN "k6n/1p6/1K6/7B/8/P7/8/8 w - - 4 3"]
        [SetUp "1"]
        [UTCDate "2025.04.04"]
        [UTCTime "20:01:57"]
        
                 1. e4 $0 e5 $1*
        
        
        [Event "Square Control: Chapter 3"]
        [Site "https://lichess.org/study/jIEHYquv/Pr8YkOZb"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/jk_182"]
        [StudyName "Square Control"]
        [ChapterName "Chapter 3"]
        [FEN "2r1r1k1/1pq1np1p/p3p1p1/3pP3/5Q2/P1P5/1P1NRPPP/4R1K1 b - - 4 22"]
        [SetUp "1"]
        [UTCDate "2025.04.04"]
        [UTCTime "19:53:06"]
        
        1. e4 $0 e5 $1*
        """
        
        let parser = PGNParser()
        do {
            let result = try parser.parse(input)
            print(result)
            #expect(result.games.count == 3)
        } catch {
            print(error)
            throw(error)
        }
       
    }
    
    @Test("PGN without moves")
    func PGNGameWithoutMoves() async throws {
        let input =
        """
        [Event "Square Control: Chapter 1"]
        [Site "https://lichess.org/study/jIEHYquv/Y8W0R708"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/jk_182"]
        [StudyName "Square Control"]
        [ChapterName "Chapter 1"]
        [FEN "r5k1/pppr1ppp/8/8/8/8/PPP1RPPP/4R1K1 w - - 0 1"]
        [SetUp "1"]
        [UTCDate "2025.04.04"]
        [UTCTime "19:57:03"]
        
         *
        
        
        [Event "Square Control: N. Kralin, O. Pervakov, 1998 (end of study)"]
        [Site "https://lichess.org/study/jIEHYquv/d7sN1Gfa"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/jk_182"]
        [StudyName "Square Control"]
        [ChapterName "N. Kralin, O. Pervakov, 1998 (end of study)"]
        [FEN "k6n/1p6/1K6/7B/8/P7/8/8 w - - 4 3"]
        [SetUp "1"]
        [UTCDate "2025.04.04"]
        [UTCTime "20:01:57"]
        
         *
        
        [Event "Square Control: Chapter 3"]
        [Site "https://lichess.org/study/jIEHYquv/Pr8YkOZb"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/jk_182"]
        [StudyName "Square Control"]
        [ChapterName "Chapter 3"]
        [FEN "2r1r1k1/1pq1np1p/p3p1p1/3pP3/5Q2/P1P5/1P1NRPPP/4R1K1 b - - 4 22"]
        [SetUp "1"]
        [UTCDate "2025.04.04"]
        [UTCTime "19:53:06"]
        
         *
        """
        let parser = PGNParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.games.count == 3)
    }
}
