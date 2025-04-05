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

        let sanParse = SanMoveParser()

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
    }
    
    @Test("test only variations")
    func parseVariations() async throws {
        let blackVariation = "(5... Nd6 6. Nxe5 Be7 7. Nxc6 dxc6 8. Bf1 Bf5 9. c3 O-O 10. d4 Re8 11. Nd2 Nb5)"
        let parser = VariationParser()
        let result = try parser.parse(blackVariation)
        #expect(result.count == 7)
    }
    
    @Test("Test black variation")
    func testPGNWithBlackVariation() async throws {
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

        let parser = PGNGameParser()
        let result3 = try parser.parse(input3)
        print(result3)
        #expect(result3.tags.count == 11)
        #expect(result3.elements.count == 5)
    }
    
    @Test("Test white variation")
    func testPGNWithWhiteVariation() async throws {
        let input3 =
        """
        [Event "23/24 season PGN: Danny Graham (1714) - Freddie Vesey (1754)"]
        [Site "https://lichess.org/study/q5HyYwEt/QjPT2O7r"]
        [Result "*"]
        [Annotator "https://lichess.org/@/Insipio"]
        [Variant "Standard"]
        [ECO "D15"]
        [Opening "Slav Defense: Schlechter Variation"]
        [StudyName "23/24 League games PGN"]
        [ChapterName "23/24 season PGN: Danny Graham (1714) - Freddie Vesey (1754)"]
        [UTCDate "2024.08.02"]
        [UTCTime "20:48:14"]
        
        1. d4 d5 2. c4 c6 3. Nc3 Nf6 4. Nf3 g6 5. Bg5 h6 6. Bxf6 exf6 7. cxd5 cxd5 8. e3 a6 9. Qb3 Be6 10. Qxb7 Nd7 11. Qb3 Bd6 12. Bd3 O-O 13. O-O h5 14. Qc2 Qe7 15. Rfe1 Bg4 16. Nxd5 Qe6 17. Nf4 (17. Be4 f5 18. Ng5 Qe8 19. Bf3 Bxf3 20. Nxf3) 17... Qe7 18. Nd2 Rfc8 19. Nd5 Qd8 20. Qa4 Nf8 21. Ne4 Nh7 22. Nxd6 Qxd6 23. Qa5 Rab8 24. Nf4 Rxb2 25. Qxa6 Qb4 26. Be2 Bd7 27. Nd3 Qc3 28. Nxb2 Qxb2 29. Rab1 Qd2 30. Red1 Qc2 31. Bd3 Qc7 32. Qa3 Qd8 33. h3 Ng5 34. Rbc1 Ra8 35. Qb2 Be6 36. Bc4 Bf5 37. h4 Ne4 38. Bd3 Qe8 39. Bxe4 Qxe4 40. d5 Qxh4 41. d6 Qg4 42. Rd4 Qg5 43. d7 Bh3 44. d8=Q+ Kg7 45. Qxa8 *
        """
        
        let parser = PGNGameParser()
        let result3 = try parser.parse(input3)
        print(result3)
        #expect(result3.tags.count == 11)
        #expect(result3.elements.count == 45)
    }
    
    @Test("Test multiple variations")
    func testPGNWithMultipleVariations() async throws {
        let input =
        """
        [Event "Londres Enigmático (PGN): 3️⃣El negro juega con Cf6 y c5"]
        [Site "https://lichess.org/study/hLXVvEvQ/nN705kYf"]
        [Date "????.??.??"]
        [White "ANALISIS Cf6-c5"]
        [Result "*"]
        [Annotator "Pepe Cuenca"]
        [Variant "Standard"]
        [ECO "A45"]
        [Opening "Indian Defense"]
        [StudyName "Londra Sistemi Tuzakları"]
        [ChapterName "Londres Enigmático (PGN): 3️⃣El negro juega con Cf6 y c5"]

        1. d4 Nf6 2. Bf4 c5 3. dxc5 { Cuando el negro juega con Cf6 y c5, esta va a ser mi recomendación, en muchas líneas vamos a defender el peón extra y quedarnos con ventaja. } 3... Nc6 { [%cal Re7e5] } 4. Nf3 { [%csl Ge5] } 4... Qa5+ 5. Nc3 Qxc5 (5... Ne4 6. Qd3 Nxc3 7. Qxc3 Qxc3+ 8. bxc3) 6. e4 Qb4 7. a3 { ¡Uy! Nos hemos dejado el peón de b2... } 7... Qxb2 { ... ¿Seguro? TRUQUITO ENIGMÁTICO ✨ } 8. Na4 { La dama queda ATRAPADA 😵 } { [%csl Rb2] } *
        """
        let parser = PGNGameParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.tags.count == 11)
        #expect(result.elements.count == 8)
    }

    @Test("All color square anotations")
    func colorAnotationSquares() async throws {
        let input =
        """
        [Event "CSL Color example"]
        [Site "Fischer-Core Test Collection"]
        [Date "2025.04.04"]
        [Round "-"]
        [White "-"]
        [Black "-"]
        [Result "*"]

        1. e4 {[%csl Ra1,Gb2,Bc3,Yd4,Me5,Cf6]} 1... e5 *
        """
        let parser = PGNGameParser()
        let result = try parser.parse(input)
        guard case let .squareList(squares) = result.elements[0].postWhiteCommentList?[0] else {
            Issue.record("no square color list")
            return
        }
        #expect(squares.count == 6)
    }

    @Test("All color arrow annotations")
    func colorArrowAnnotations() async throws {
        let input =
        """
        [Event "CAL Arrow example"]
        [Site "Fischer-Core Test Collection"]
        [Date "2025.04.04"]
        [Round "-"]
        [White "-"]
        [Black "-"]
        [Result "*"]

        1. e4 {[%cal Ra1a8,Gb2b4,Bc3f3,Yd4d8,Me5e7,Cf6h6]} 1... e5 *
        """
        let parser = PGNGameParser()
        let result = try parser.parse(input)
        guard case let .arrowList(arrows) = result.elements[0].postWhiteCommentList?[0] else {
            Issue.record("no arrow color list")
            return
        }
        #expect(arrows.count == 6)
    }
    @Test("real Lichess game example")
    func realLichessGame() async throws{
        let input =
        """
        [Event "FIDE Women's World Championship Match 2025"]
        [Site "Shanghai, China"]
        [Date "2025.04.03"]
        [Round "1"]
        [White "Ju, Wenjun"]
        [Black "Tan, Zhongyi"]
        [Result "1/2-1/2"]
        [WhiteElo "2561"]
        [WhiteFideId "8603006"]
        [BlackElo "2555"]
        [BlackFideId "8603642"]
        [Annotator "https://lichess.org/@/raluca_sgircea"]
        [Variant "Standard"]
        [ECO "B40"]
        [Opening "Sicilian Defense: French Variation, Normal"]
        [StudyName "Women's World Championship 2025: Annotated Games"]
        [ChapterName "Ju, Wenjun - Tan, Zhongyi (Sgîrcea)"]

        { The match kicked off with a solid game. It often happens that the first round of a long match is rather quiet. Both players prefered to be on the safe side, take no big risks and get a feel for the match. As Tan said in the post-game press conference, it is important to find the right tempo for the rest of the games. }
        1. e4 { A predominantly 1.d4 player, Ju decided to start the first game with 1.e4, perhaps to try to surprise her opponent. } 1... c5 2. Nf3 e6 3. d4 cxd4 4. Nxd4 Nf6 5. Bd3 { Ju opts for a sideline, possibly to avoid the Four Knights variation of the Sicilian. Although far less popular than the 5.Nc3 alternative, this line has lately come back in fashion. Initially, it was made popular by Argentinian Grandmaster Daniel Campora. Nowadays, it has been seen at high level and tried by players like Carlsen, Anand, Nakamura or Abdusattorov. } (5. Nc3 { is the main line, leading to the Four Knights Variation after } 5... Nc6) 5... Nc6 6. Nxc6 bxc6 7. Bf4 { Again, the World Champion opts for a sideline. This is only the 3rd most popular choice according to my database, but it has seen a rise in popularity in the recent year. } 7... d5 8. Nd2 g6 9. Bg5 { Both players have been blitzing out their moves. Bg5 was probably Ju's preparation, as it has only been played once before. } 9... h6 { The first new move of the game and the first moment where the Challenger stopped to think. She admitted that she was a bit surprised by Ju Wenjun's move, but decided to play sensible moves and not spend too much time thinking. } (9... Be7 { is how the only other game in the database continued, but Tan Zhongyi was most likely bothered by } 10. Bh6 e5 11. h3 Bf8 12. Bxf8 Kxf8 13. O-O Kg7 14. Re1 Re8 { and black was fine, although eventually lost the game in Heimann,M (2467)-Zeltsan,J (2417) Rockville USA 2024 }) 10. Bh4 Be7 11. O-O a5 { preparing Ba6 } 12. Qe2 { A logical square for the white Queen, also preventing Black's idea } 12... O-O 13. Rad1 { Another logical developing move } 13... Nd7 14. Bxe7 (14. Bg3 { was the alternative but now, after having broken the pin, Black can follow up with } 14... Qb6 { her development after Rd8 and Ba6 } { [%cal Gc8a6,Gf8d8] }) 14... Qxe7 15. c4 (15. Rfe1 Bb7 16. Nf3 Rfd8 { white keeps a small edge }) 15... Ne5 { threatening to follow up with Ba6 } 16. exd5 Nxd3 17. Qxd3 cxd5 18. Qe3 (18. cxd5 { wins a pawn, but Black gets very active and eventually wins the pawn back after } 18... Ba6 19. Nc4 exd5 20. Qxd5 Rfd8 21. Qc6 Rdc8 22. Qd6 Qxd6 23. Nxd6 Rc2 24. Rfe1 Rxb2) 18... Qg5 19. Qxg5 hxg5 20. cxd5 exd5 21. Rfe1 Rb8 22. b3 g4 { White was threatening Nf3 } 23. Nf1 { The only other route to improve the position of this knight } 23... a4 { Tan goes for active play, trading her weaknesses on a5 and d5 fore white's queenside pawns } 24. bxa4 Rb4 25. a5 (25. Rxd5 Rxa4 26. Rd2 { makes no difference, as black can continue with } 26... Be6 { and still win the a2 pawn }) 25... Ra4 26. Rxd5 Be6 27. Rc5 Rxa2 28. Ne3 Ra8 29. Nd5 R8xa5 30. Rxa5 Rxa5 31. Nf4 Bf5 32. h3 gxh3 33. Nxh3 Bxh3 34. gxh3 Kg7 35. Kg2 Rg5+ 36. Kf3 Rf5+ 37. Kg2 Rg5+ 38. Kf3 Rf5+ 39. Kg2 { A solid, calm game. Today we saw that both players were very well prepared, played very fast and almost all moves were top engine moves. The tension will build up and it's interesting to see what the rest of the games will bring. } 1/2-1/2
        """
        let parser = PGNGameParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.elements.count == 39)
    }
    
    @Test("cal ans csl comment in the same comment")
    func calAndCslSameComment() async throws{
        let input =
        """
        [Event "[NEW] CRUSH the French!: 📘 4...Nd7"]
        [Site "https://lichess.org/study/Rb4AyiUo/DsuBAZD0"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/Bosburp"]
        [StudyName "[NEW] CRUSH the French!"]
        [ChapterName "📘 4...Nd7"]
        [FEN "rnbqkbnr/ppp2ppp/4p3/8/4N3/5N2/PPPP1PPP/R1BQKB1R b KQkq - 0 4"]
        [SetUp "1"]
        [UTCDate "2025.03.31"]
        [UTCTime "10:47:15"]

        4... Nd7 { A better response. Might look weird at first, but the idea behind this move is to support Nf6 on the next move, allowing Black to recapture with the d7 knight instead of weakening the pawn structure by capturing with a pawn or bringing the queen out to early. } { [%csl Gf6][%cal Bg8f6,Yd7f6] } 5. d4 { We'll immediately take the center. } { [%csl Ge5][%cal Gd4e5] } 5... Ngf6 { Challenging our knight. } { [%csl Re4][%cal Gf6e4] } 6. Nxf6+ Nxf6 { Now Black has a knight on f6 instead of the queen, as we saw in the previous chapter. This is a much more solid approach. } { [%csl Gf6] } 7. g3! { Here, I recommend playing g3, going for the LSB fianchetto and an O-O setup. I think most players will mess up by trying to force an attack or action too soon, but there isn’t anything, Black’s setup is still quite solid. The best option here is to calmly continue developing all our pieces. No need to rush. } { [%csl Bg1][%cal Bf1g2,Be1g1] } 7... Be7 (7... c5 8. Bg2 $16 { Same idea. Of course, if Black captures d4, recapture. } { [%csl Gg2][%cal Be1g1,Ba2a4,Bc2c4] }) (7... b6 { Top engine move. Black also wants to place the LSB somewhere active. } { [%cal Bc8b7,Gb7h1,Gb7a8] } 8. Bg2 { We just continue our plan. } 8... Bb7 9. O-O Be7 10. Qe2 { Many developing moves work here. But I like to get the f1 rook to the d-file. } 10... O-O 11. Rd1 $14 { White has a small edge, but it's equal with perfect play. White's winrate is at 55%. } { [%csl Gd1,Ge2][%cal Bc2c4,Bb2b3,Bc1b2,Ba2a4] }) 8. Bg2 O-O 9. O-O $16 { We’ve finished our kingside development, and there’s nothing to complain about in our position. From here, just play chess! White has a 58% win rate. } { [%csl Gg2,Gg1,Rc8][%cal Bc2c4,Bf3e5,Bf1e1,Bd1e2] } *
        """
        let parser = PGNGameParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.elements.count == 6)
    }
    
    @Test("multiples nags in one move")
    func multiplesNagsSameMove() async throws {
        let input =
        """
        [Event "Fighting against London: Bishop Kicking!"]
        [Site "https://lichess.org/study/Q7v33IGE/7W2bZKD5"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "A45"]
        [Opening "Indian Defense"]
        [Annotator "https://lichess.org/@/delta_horsey"]
        [StudyName "Fighting against London"]
        [ChapterName "Bishop Kicking!"]
        [UTCDate "2025.03.24"]
        [UTCTime "00:41:42"]
        
        1. d4 Nf6 2. Bf4 b6!? (2... d5 3. e3 c5 4. c3 Nc6 5. Nd2 e6 6. Ngf3 Bd6 7. Bg3 O-O 8. Bd3) 3. e3 Bb7 4. Nf3 Nh5! 5. Bg5 (5. Bg3 Nxg3 6. hxg3 g6 7. c4 Bg7 8. Nc3 O-O 9. Bd3 e6 $36 10. Be4?! d5! 11. cxd5 exd5 12. Bd3 c5 $15) 5... h6 6. Bh4 g5 7. Nfd2 (7. Ne5 Nf6 8. Bg3 d6 9. Nc4 Ne4!? $13) (7. Bg3 Nxg3 8. hxg3 Bg7 9. Nbd2 e6 10. c3 d5 11. a4 a6! $10) 7... Nf4! 8. exf4 gxh4 9. Nf3 (9. Qh5?! e6 10. Nc3 Qf6! 11. Qe5 Qxe5+ 12. dxe5 Nc6 13. O-O-O O-O-O 14. Rg1 d6 $36) (9. h3? e6 10. Nc3 Qf6! $17) 9... e6 10. Nbd2 c5! 11. dxc5 bxc5 12. g3 Be7 13. Bg2 Nc6 $13 *
        """
        
        let parser = PGNGameParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.elements.count == 13)
    }
    
    @Test func allNagvalues() async throws {
        let input =
        """
        [Event "NAG Full Test"]
        [Site "Local"]
        [Date "2025.04.04"]
        [Round "-"]
        [White "NAGTest"]
        [Black "NAGTest"]
        [Result "*"]

        1. e4 $0 e5 $1
        2. Nf3 $2 Nc6 $3
        3. Bb5 $4 a6 $5
        4. Ba4 $6 Nf6 $7
        5. O-O $8 Be7 $9
        6. Re1 $10 b5 $11
        7. Bb3 $12 d6 $13
        8. c3 $14 O-O $15
        9. h3 $16 Nb8 $17
        10. d4 $18 Nbd7 $19
        11. Nbd2 $20 Bb7 $21
        12. Bc2 $22 Re8 $23
        13. a4 $24 Bf8 $25
        14. Bd3 $26 g6 $27
        15. Qc2 $28 c5 $29
        16. d5 $30 c4 $31
        17. Bf1 $32 Nc5 $33
        18. a5 $34 Rc8 $35
        19. Nh2 $36 Bg7 $37
        20. Ng4 $38 Nxg4 $39
        21. hxg4 $40 Qh4 $41
        22. Qd1 $42 Rc7 $43
        23. g3 $44 Qe7 $45
        24. Bg2 $46 Bc8 $47
        25. Nf1 $48 f5 $49
        26. gxf5 $50 Bxf5 $51
        27. exf5 $52 Bxf5 $53
        28. Ne3 $54 Bd3 $55
        29. Qh5 $56 Qf8 $57
        30. Bd2 $58 Rf7 $59
        31. Bf1 $60 Bg6 $61
        32. Qh2 $62 e4 $63
        33. Be2 $64 Be5 $65
        34. Qh4 $66 Rxf2 $67
        35. Ng4 $68 e3 $69
        36. Bxe3 $70 Rxe2 $71
        37. Rxe2 $72 Qf3 $73
        38. Rxe2 $74 Qxg3+ $75
        39. Rf2 $76 Bxg3 $77
        40. Qxg3 $78 Kg7 $79
        41. Qxg3 $80 Kg8 $81
        42. Rf6 $82 Re1 $83
        43. Bh6+ $84 Kg7 $85
        44. Raf1 $86 Kg8 $87
        45. Rxf8# $88 Re1 $89
        46. e3 $90 Kh8 $91
        47. Na3 $92 c5 $93
        48. Nb5 $94 c6 $95
        49. b3 $96 Nc6 $97
        50. a3 $98 Nd7 $99
        51. Qa1 $100 Nf6 $101
        52. Qa4 $102 Ng6 $103
        53. Qc3 $104 Qb6 $105
        54. Qc4 $106 Qc7 $107
        55. Qd3 $108 Qd6 $109
        56. Qd4 $110 Qe7 $111
        57. Qe3 $112 Qf6 $113
        58. Qe4 $114 Qg7 $115
        59. Qf3 $116 Qh6 $117
        60. Qf4 $118 Kg6 $119
        61. Qg3 $120 Kg7 $121
        62. Qg4 $122 Kg8 $123
        63. Qh3 $124 Kh7 $125
        64. Qh4 $126 Kh8 $127
        65. Ke2 $128 b5 $129
        66. Kf2 $130 c4 $131
        67. Kg2 $132 e5 $133
        68. Kh2 $134 Nc6 $135
        69. a4 $136 a6 $137
        70. b4 $138 Nf6 $139
        *
        """
        
        let parser = PGNGameParser()
        let result = try parser.parse(input)
        print(result)
        #expect(result.elements.count == 70)
    }
}
