//
//  PGNParserTests.swift
//  FischerCore
//
//  Created by Omar Megdadi on 16/11/25.
//
import Foundation
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
    
    @Test("PGN TWIC")
    func PGNGameTWIC() async throws {
        let input =
        """
        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Gukesh,D"]
        [Black "Nogerbek,Kazybek"]
        [Result "1/2-1/2"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2763"]
        [BlackElo "2538"]
        [ECO "A13"]
        [Opening "English"]
        [Variation "Neo-Catalan"]
        [WhiteFideId "46616543"]
        [BlackFideId "13710427"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. Nf3 d5 2. c4 e6 3. g3 Nf6 4. Bg2 d4 5. O-O Nc6 6. d3 Bc5 7. Nbd2 O-O 8. Nb3
        Be7 9. h3 e5 10. e3 dxe3 11. Bxe3 a5 12. d4 exd4 13. Nbxd4 Nxd4 14. Bxd4 Nd7 15.
        Qb3 Bf6 16. Rad1 Re8 17. Be3 Qe7 18. Rfe1 Qf8 19. Qc2 Ra6 20. Nd4 Be5 21. f4 Bd6
        22. Bf2 Rxe1+ 23. Rxe1 c6 24. Nf5 Bb4 25. Re2 g6 26. Nh6+ Kg7 27. Ng4 h5 28.
        Bd4+ Kh7 29. Nf2 Bc5 30. Qc3 Bxd4 31. Qxd4 c5 32. Qc3 Nf6 33. Bf3 Qd6 34. Re5
        Qd4 35. Qxd4 cxd4 36. Nd3 Kg7 37. Nc5 Rd6 38. Nxb7 Bxb7 39. Bxb7 d3 40. Bf3 d2
        41. Bd1 Rd4 42. Kf2 Rxc4 43. Ke3 Rb4 44. b3 a4 45. bxa4 Rb2 46. a3 Ra2 47. Ke2
        Rxa3 48. Re3 Ra1 49. Kxd2 h4 50. gxh4 Nd5 51. Re8 Nxf4 52. Bb3 Ne6 53. Rc8 Nd4
        54. Bd1 Kf6 55. Rc1 Ra3 56. Rc3 Ra1 57. Re3 Kf5 58. Re7 f6 59. Rg7 Ra3 60. Bg4+
        Ke5 61. Rxg6 Rxa4 62. h5 Ra7 63. h6 Rh7 64. h4 Nf5 65. Bxf5 Kxf5 66. h5 Ke6 67.
        Ke3 Kf7 68. Kf4 Kf8 69. Kf5 Kf7 70. Ke4 Kf8 71. Kf4 Ra7 72. Rg1 Rh7 73. Rg6 Ra7
        74. Kf5 Ra5+ 75. Kg4 Ra4+ 76. Kf3 Ra3+ 77. Ke4 Ra4+ 78. Kd3 Ra3+ 79. Kc4 Ra4+
        80. Kb5 Rh4 81. Rxf6+ Kg8 82. h7+ Kxh7 83. h6 Rxh6 84. Rxh6+ Kxh6 1/2-1/2

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Petrov,Martin"]
        [Black "Erigaisi,Arjun"]
        [Result "0-1"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2548"]
        [BlackElo "2769"]
        [ECO "C50"]
        [Opening "Giuoco Pianissimo"]
        [WhiteFideId "2911086"]
        [BlackFideId "35009192"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. d3 Nf6 5. O-O d6 6. a4 O-O 7. a5 a6 8. Be3
        Bxe3 9. fxe3 Ne7 10. Nc3 Ng6 11. h3 c6 12. d4 Qe7 13. d5 Bd7 14. Nd2 Rac8 15.
        dxc6 Bxc6 16. Qe2 Bd7 17. Qd3 Be6 18. Na4 Nd7 19. Kh2 Nc5 20. Nxc5 Rxc5 21. Bxe6
        Qxe6 22. c4 Ne7 23. Rfd1 Rd8 24. b3 Qc8 25. Kh1 h6 26. Ra2 Qc7 27. b4 Rc6 28.
        Rc2 Qd7 29. Nb3 Rc7 30. Rcd2 Qa4 31. c5 d5 32. exd5 Rxd5 33. Qc2 Rcd7 34. Rxd5
        Rxd5 35. Rxd5 Nxd5 36. Qc4 Nxb4 37. Qg4 Qxb3 0-1

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Praggnanandhaa,R"]
        [Black "Kuybokarov,Temur"]
        [Result "1/2-1/2"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2768"]
        [BlackElo "2535"]
        [ECO "D02"]
        [Opening "Queen's pawn game"]
        [WhiteFideId "25059530"]
        [BlackFideId "14203049"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. d4 d5 2. Nf3 Nf6 3. c4 e6 4. g3 Bb4+ 5. Bd2 Be7 6. Bg2 O-O 7. O-O Nbd7 8. Qc2
        c6 9. b3 b6 10. Bc3 Ba6 11. Nbd2 c5 12. dxc5 Bxc5 13. Qb2 Re8 14. cxd5 exd5 15.
        b4 Bf8 16. b5 Bb7 17. Nd4 Nc5 18. a4 a6 19. Bb4 a5 20. Bc3 Rc8 21. Rfd1 Rc7 22.
        Nc6 Bxc6 23. Bxf6 Qxf6 24. Qxf6 gxf6 25. bxc6 Rxc6 26. Bxd5 Rc7 27. e3 Rd8 28.
        Nc4 Rb8 29. Rd4 Rd7 30. Ra2 Na6 31. Rad2 b5 32. axb5 Rxb5 33. Bc6 Rxd4 34. Rxd4
        Rc5 35. Ba4 Nc7 36. Nb6 Ne6 37. Rd1 Kg7 38. Nd5 Rc8 39. Ra1 Bd6 40. Kg2 Rc5 41.
        Bb3 Nc7 42. Nxc7 Bxc7 43. Rd1 Rc3 44. Ba4 Rc4 45. Bb5 Rc5 46. Bd7 Bd8 47. Ba4
        Be7 48. Rd7 Kf8 49. Ra7 h6 50. Kf3 Rh5 51. h4 Re5 52. Ke2 Bb4 53. Bb3 Re7 54.
        Ra6 Kg7 55. g4 Rc7 56. h5 Rc3 57. Bd5 Rc5 58. e4 Rc2+ 59. Kd3 Rc3+ 60. Ke2 Rc2+ 1/2-1/2

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Maksimovic,Bojan"]
        [Black "Giri,A"]
        [Result "1/2-1/2"]
        [WhiteTitle "IM"]
        [BlackTitle "GM"]
        [WhiteElo "2532"]
        [BlackElo "2769"]
        [ECO "A45"]
        [Opening "Trompovsky attack (Ruth, Opovcensky opening)"]
        [WhiteFideId "14408120"]
        [BlackFideId "24116068"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. d4 Nf6 2. Bg5 c5 3. Bxf6 gxf6 4. d5 Qb6 5. Qc1 f5 6. g3 Bg7 7. c3 d6 8. Bg2
        Nd7 9. Nf3 Nf6 10. Nh4 e6 11. O-O O-O 12. Qc2 Bd7 13. Nd2 Qc7 14. Rad1 Rad8 15.
        Rfe1 Bc8 16. e4 fxe4 17. Nxe4 Rfe8 18. Nxf6+ Bxf6 19. Qe4 Qe7 20. dxe6 Qxe6 21.
        Qb1 Qd7 22. Nf3 d5 23. h4 Rxe1+ 24. Nxe1 d4 25. c4 Re8 26. Bf1 Qg4 27. Ng2 b6
        28. Re1 Rxe1 29. Qxe1 Qe6 30. Qd2 Bg7 31. Qg5 f6 32. Qh5 Qf7 33. Qxf7+ Kxf7 34.
        Bd3 f5 35. Kf1 Be5 36. Ke2 Kf6 37. Ne1 Bd6 38. Nf3 f4 39. g4 Bxg4 40. Bxh7 Kg7
        41. Be4 Kh6 42. Bd5 Bf5 43. Bf7 Be7 44. Ke1 Bf6 45. h5 Bb1 46. Nd2 Bxa2 47. Ke2
        d3+ 48. Kxd3 Bxb2 49. Kc2 Bd4 50. f3 b5 51. Nb3 Kg7 52. Be8 Bxb3+ 53. Kxb3 b4
        54. Bc6 Kh6 55. Be8 Kg5 56. Ka4 Bg7 57. Kb3 Bd4 58. Ka4 Bg7 59. Kb3 Kh4 60. Bf7
        Kg3 61. Bd5 Kf2 62. Bc6 Ke3 63. Bb7 Kd4 64. Bc6 a5 65. Bd7 Kd3 66. Bc6 Ke2 67.
        Bb7 Ke3 68. Bc6 Kd3 69. Bd7 Kd4 70. Bc6 Bh6 71. Bd7 Ke3 72. Bc6 Kd3 73. Bd7 Ke3
        74. Bc6 Kd3 75. Bd7 Ke2 76. Bc6 Ke3 77. Bb7 Kd3 78. Bc6 1/2-1/2

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "So,W"]
        [Black "Stremavicius,T"]
        [Result "1/2-1/2"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2764"]
        [BlackElo "2544"]
        [ECO "C17"]
        [Opening "French"]
        [Variation "Winawer, advance, 5.a3"]
        [WhiteFideId "5202213"]
        [BlackFideId "12804444"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. e4 e6 2. d4 d5 3. Nc3 Bb4 4. e5 c5 5. a3 Ba5 6. Qg4 Ne7 7. dxc5 Bxc3+ 8. bxc3
        O-O 9. Bd3 Nd7 10. Nf3 Nf5 11. O-O Nxc5 12. Qh5 Nxd3 13. cxd3 b6 14. Re1 Qc7 15.
        Bd2 Bd7 16. Rab1 a5 17. Ng5 h6 18. Nf3 f6 19. exf6 Rxf6 20. Ne5 b5 21. c4 Be8
        22. Qg4 h5 23. Qh3 bxc4 24. dxc4 dxc4 25. Bg5 Rf8 26. Rbc1 Rc8 27. Rxc4 Qb7 28.
        Rce4 Qd5 29. Nf3 Bf7 30. Bd2 Rc2 31. Re5 Qa2 32. Bxa5 Qxa3 33. Ng5 Qxh3 34. Nxh3
        Rb8 35. Ng5 Nd4 36. h4 Nc6 37. Nxf7 Kxf7 38. Rxh5 Rbb2 39. Rf1 Nd4 40. Rg5 Ne2+
        41. Kh2 Nf4 42. Rd1 Nd5 43. Rd3 Ra2 44. Be1 Ra4 45. f3 Raa2 46. Rb3 g6 47. h5
        gxh5 48. Rb7+ Rc7 49. Rb8 Rcc2 50. Rb7+ Rc7 51. Rb8 Rcc2 52. Rbg8 Ke7 53. R8g7+
        Kd6 54. Bg3+ Kc6 55. Be5 Ne3 56. Rc7+ Kd5 57. Bb2+ Kd6 58. Be5+ Kd5 59. Bf4+ Nf5
        60. Rxc2 Rxc2 61. Rxh5 Rc4 62. Bg3 Rc2 63. Bf4 Rc4 64. Bg3 Rc2 65. Rg5 Kc6 66.
        Kh3 Re2 67. Bh2 Kd7 68. Rg4 Ke7 69. Ra4 e5 70. Bg1 Kf6 71. g4 Ng7 72. Ra3 Ne6
        73. Be3 Kg6 74. Kg3 Kf6 75. Rb3 Kg6 76. Bc1 Nc5 77. Rc3 Ne6 78. Rb3 Nc5 79. Rb6+
        Kf7 80. g5 Nd3 81. g6+ Kg7 82. Bg5 Re1 83. Kg4 Rf1 84. Bd2 Rf2 85. Bc3 Kh6 86.
        Rd6 Rg2+ 87. Kh4 Nc5 88. Bd2+ Kg7 89. Bg5 Nb3 90. f4 Nc5 91. Kh5 Rh2+ 92. Kg4
        exf4 93. Bxf4 Rg2+ 94. Kh5 Kf8 95. Kh6 Ke7 96. Rd5 Ne6 97. Rf5 Ke8 98. Rf6 Ke7
        99. Rf7+ Kd8 100. Be5 Ke8 101. Bd6 Kd8 102. Re7 Rh2+ 103. Bxh2 Kxe7 104. Be5 Kf8
        105. Kh7 Ng5+ 106. Kh8 Nf7+ 107. gxf7 Kxf7 1/2-1/2

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Kovalev,Vl"]
        [Black "Keymer,Vincent"]
        [Result "0-1"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2557"]
        [BlackElo "2773"]
        [ECO "C44"]
        [Opening "Scotch gambit"]
        [Variation "Dubois-Reti defence"]
        [WhiteFideId "13504398"]
        [BlackFideId "12940690"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. e4 e5 2. Nf3 Nc6 3. Bc4 Nf6 4. d4 exd4 5. e5 Ne4 6. O-O Be7 7. Bd5 Nc5 8. c3
        dxc3 9. Nxc3 O-O 10. Be3 d6 11. exd6 cxd6 12. Qe2 Ne6 13. Rad1 Nc7 14. Bf4 Re8
        15. Be4 Ne6 16. Be3 Bf8 17. a3 g6 18. b4 Ne7 19. Nb5 d5 20. Nxa7 dxe4 21. Rxd8
        exf3 22. Rxe8 fxe2 23. Re1 Nc7 24. Rd8 Bf5 25. Rxa8 Nxa8 26. Rxe2 Nc7 27. Bc5
        Ned5 28. Bxf8 Kxf8 29. f3 Nc3 30. Re1 N7d5 31. Kf2 h5 32. g3 Be6 33. Rc1 Ke7 34.
        Ke1 Bf5 35. Kf2 Bd7 36. Ke1 Kd6 37. Kd2 Kc7 38. a4 Bxa4 39. b5 Kb8 40. b6 Bd7
        41. Rxc3 Nxb6 42. g4 hxg4 43. fxg4 Kxa7 44. h3 Be6 45. Ra3+ Kb8 46. Kd3 Kc7 47.
        Kd4 Kd6 48. Ra7 Kc6 49. Ke5 Nd7+ 50. Kf4 b5 51. Kg5 b4 52. h4 b3 53. Ra1 Bc4 54.
        Rd1 Nc5 55. h5 Ne4+ 56. Kf4 Nf2 57. Rd2 g5+ 58. Kf3 Nd3 59. h6 Ne5+ 60. Ke4 f6
        61. h7 b2 62. Kd4 b1=Q 63. h8=Q Qg1+ 64. Kc3 Qc1+ 65. Rc2 Qa3+ 66. Kd2 Nf3+ 0-1

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Wei Yi"]
        [Black "Piorun,K"]
        [Result "1-0"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2753"]
        [BlackElo "2557"]
        [ECO "C53"]
        [Opening "Giuoco Piano"]
        [Variation "LaBourdonnais variation"]
        [WhiteFideId "8603405"]
        [BlackFideId "1130420"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. c3 d6 5. d4 exd4 6. cxd4 Bb6 7. Nc3 Nf6 8. Be3
        Nxe4 9. Nxe4 d5 10. Bb3 dxe4 11. Ng5 Be6 12. Nxe6 fxe6 13. O-O Bxd4 14. Qh5+ g6
        15. Qg4 Qf6 16. Bxe6 Ne5 17. Qxe4 Bxe3 18. Bf7+ Kxf7 19. fxe3 Rhe8 20. Qxb7
        Qxf1+ 21. Rxf1+ Kg8 22. Qxc7 a5 23. a4 Rad8 24. Qxa5 Nc4 25. Qc3 Nd2 26. Rd1 1-0

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Makhnev,Denis"]
        [Black "Abdusattorov,Nodirbek"]
        [Result "1/2-1/2"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2525"]
        [BlackElo "2750"]
        [ECO "D02"]
        [Opening "Queen's bishop game"]
        [WhiteFideId "13707647"]
        [BlackFideId "14204118"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. d4 d5 2. Nf3 Nf6 3. Bf4 c5 4. e3 Nc6 5. Nbd2 Bg4 6. c3 e6 7. Bb5 cxd4 8. exd4
        Bd6 9. Bxd6 Qxd6 10. O-O O-O 11. Qe1 Bf5 12. Nh4 Rfe8 13. Nxf5 exf5 14. Qd1 g6
        15. Re1 Rxe1+ 16. Qxe1 Re8 17. Qf1 Ne4 18. Re1 Rc8 19. Nb3 Nd8 20. f3 Nf6 21.
        Qf2 Ne6 22. Nc1 Kg7 23. Bf1 Nf4 24. Qg3 Rd8 25. Re5 Ne6 26. Nd3 h5 27. Re1 Qb6
        28. Qf2 Rc8 29. Qg3 Rh8 30. h4 Rc8 31. Qe5 Re8 32. Qg3 Rc8 33. Qe5 Re8 34. Qg3
        Qa5 35. a3 Qb6 36. Kh1 Qd8 37. Kg1 Qb6 38. Kh1 Rc8 39. Re2 Qd8 40. Kg1 Rc6 41.
        Qe5 Kg8 42. Qg3 Rb6 43. Nc5 Nxc5 44. dxc5 Rc6 45. Qf2 Qc8 46. b4 b6 47. cxb6
        axb6 48. Qd4 Kg7 49. Re5 Rxc3 50. Rxd5 Rxa3 51. Bc4 Qe8 52. Re5 Qf8 53. Rb5 Qe7
        54. Rxb6 Ra4 55. Bb3 Ra3 56. Bc4 Ra4 57. Bxf7 Ra1+ 58. Qxa1 Qe3+ 59. Kf1 Qxb6
        60. Bb3 Qxb4 61. Qa7+ Kh6 62. Qe3+ Kg7 63. Qa7+ Kh6 64. Qe3+ Kg7 65. Qa7+ Kh6
        66. Qe3+ 1/2-1/2

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Mamedyarov,S"]
        [Black "Kantor,G"]
        [Result "1-0"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2742"]
        [BlackElo "2546"]
        [ECO "A22"]
        [Opening "English opening"]
        [WhiteFideId "13401319"]
        [BlackFideId "751499"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. c4 e5 2. Nc3 Nf6 3. e3 Nc6 4. Qb3 a5 5. Nf3 Bb4 6. a3 Bxc3 7. Qxc3 Qe7 8. b3
        d5 9. cxd5 Nxd5 10. Qc2 e4 11. Ng1 O-O 12. Bb2 Bf5 13. f4 exf3 14. Qxf5 Nxe3 15.
        Qxf3 Nd4 16. Bxd4 Qh4+ 17. g3 Qxd4 18. Ra2 Ng4 19. Be2 Rae8 20. Kf1 Ne5 21. Qf4
        Qd5 22. Nf3 a4 23. Kf2 axb3 24. Rb2 c5 25. d4 Ng6 26. Qg5 Qe4 27. Re1 h6 28.
        Qxc5 Qe3+ 29. Kg2 Re6 30. Qc1 Qe4 31. Rxb3 Rfe8 32. Bc4 Nh4+ 33. Kf2 Qxf3+ 1-0

        [Event "FIDE World Cup 2025"]
        [Site "Goa IND"]
        [Date "2025.11.04"]
        [Round "2.1"]
        [White "Lodici,Lorenzo"]
        [Black "Niemann,Hans Moke"]
        [Result "1/2-1/2"]
        [WhiteTitle "GM"]
        [BlackTitle "GM"]
        [WhiteElo "2572"]
        [BlackElo "2729"]
        [ECO "C58"]
        [Opening "Two knights defence"]
        [WhiteFideId "884189"]
        [BlackFideId "2093596"]
        [EventDate "2025.11.01"]
        [EventType "k.o."]

        1. e4 e5 2. Nf3 Nc6 3. Bc4 Nf6 4. Ng5 d5 5. exd5 Na5 6. Bb5+ c6 7. dxc6 bxc6 8.
        Bd3 Nd5 9. Nf3 Bd6 10. O-O Nf4 11. Nc3 Nxd3 12. cxd3 O-O 13. Re1 c5 14. b3 Nc6
        15. Ba3 Bg4 16. h3 Bh5 17. Rc1 Re8 18. Ne4 Nb4 19. Bxb4 cxb4 20. g4 Bg6 21. Rc6
        Bf8 22. Qc2 Qd5 23. Qc4 Rad8 24. Qxd5 Rxd5 25. d4 f5 26. gxf5 Bxf5 27. Kg2 Bd7
        28. Rc7 exd4 29. Rxd7 Rxd7 30. Nf6+ gxf6 31. Rxe8 Kf7 32. Rc8 d3 33. Kg3 Bd6+
        34. Kg4 Re7 35. Kf5 Re2 36. Ra8 Rxf2 37. Rxa7+ Kg8 38. Ra8+ Kg7 39. Ke4 f5+ 40.
        Ke3 Bc5+ 41. Kf4 Bd6+ 42. Ke3 Bc5+ 43. Kf4 Bd6+ 1/2-1/2
        """
        let parser = PGNParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.games.count == 10)
    }
    
    @Test("TWIC file PGN parser", .disabled("We only check in local"))
    func parseTWICFileFromResources() async throws {
        let fileURL = try #require(
            Bundle.module.url(forResource: "twic1618", withExtension: "pgn")
        )
        
        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        let parser = PGNParser()
        let result = try parser.parse(fileContents)
        
        #expect(result.games.count == 5347)
    }
}
