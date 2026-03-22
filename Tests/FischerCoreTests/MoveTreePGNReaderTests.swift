import Testing
@testable import FischerCore

final class MoveTreePGNReaderTests {
    @Test("Reader matches direct parser on PGN with variations")
    func readerMatchesParserOnVariationRichPGN() async throws {
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

        let parsed = try MoveTreePGNParser().parse(input)
        var reader = MoveTreePGNReader(input)
        let firstRead = try reader.readGame()
        let read = try #require(firstRead)

        #expect(read == parsed)
        #expect(try reader.readGame() == nil)
    }

    @Test("Reader parses black-to-move PGN")
    func readerParsesBlackToMovePGN() async throws {
        let input =
        """
        [Event "[NEW] CRUSH the French!: 4...Nd7"]
        [Site "https://lichess.org/study/Rb4AyiUo/DsuBAZD0"]
        [Result "*"]
        [Variant "Standard"]
        [ECO "?"]
        [Opening "?"]
        [Annotator "https://lichess.org/@/Bosburp"]
        [StudyName "[NEW] CRUSH the French!"]
        [ChapterName "4...Nd7"]
        [FEN "rnbqkbnr/ppp2ppp/4p3/8/4N3/5N2/PPPP1PPP/R1BQKB1R b KQkq - 0 4"]
        [SetUp "1"]
        [UTCDate "2025.03.31"]
        [UTCTime "10:47:15"]

        4... Nd7 5. d4 Ngf6 6. Nxf6+ Nxf6 7. g3 Be7 (7... c5 8. Bg2) (7... b6 8. Bg2 Bb7 9. O-O Be7 10. Qe2 O-O 11. Rd1) 8. Bg2 O-O 9. O-O *
        """

        var reader = MoveTreePGNReader(input)
        let firstRead = try reader.readGame()
        let pgn = try #require(firstRead)
        let tree = try #require(pgn.tree)

        #expect(tree.turn == 4)
        #expect(tree.color == .black)
        #expect(pgn.result == .undefined)
        #expect(tree.mainLineTurnAndColors == [
            "4.black",
            "5.white",
            "5.black",
            "6.white",
            "6.black",
            "7.white",
            "7.black",
            "8.white",
            "8.black",
            "9.white"
        ])
    }

    @Test("Reader reads multiple games sequentially")
    func readerReadsMultipleGames() async throws {
        let input =
        """
        [Event "Game One"]
        [Result "*"]

        1. e4 e5 *

        [Event "Game Two"]
        [Result "1-0"]

        1. d4 d5 1-0
        """

        var reader = MoveTreePGNReader(input)
        let firstRead = try reader.readGame()
        let secondRead = try reader.readGame()
        let first = try #require(firstRead)
        let second = try #require(secondRead)

        #expect(first.tags[.event] == "Game One")
        #expect(first.tree?.mainLineDescriptions == ["e4", "e5"])
        #expect(first.result == .undefined)

        #expect(second.tags[.event] == "Game Two")
        #expect(second.tree?.mainLineDescriptions == ["d4", "d5"])
        #expect(second.result == .win)

        #expect(try reader.readGame() == nil)
    }
}

private extension MoveTree {
    var mainLineDescriptions: [String] {
        [node.description] + (next?.mainLineDescriptions ?? [])
    }

    var mainLineTurnAndColors: [String] {
        ["\(turn).\(color.rawValue)"] + (next?.mainLineTurnAndColors ?? [])
    }
}
