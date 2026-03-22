import Testing
@testable import FischerCore

final class MoveTreeTests {
    @Test("Build move tree main line")
    func buildMainLineTree() async throws {
        let input =
        """
        [Event "MoveTree main line"]
        [Site "Fischer-Core Test Collection"]
        [Result "*"]

        1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *
        """

        let game = try PGNGameParser().parse(input)
        let tree = try #require(game.moveTree)

        #expect(tree.mainLineDescriptions == ["e4", "e5", "Nf3", "Nc6", "Bb5", "a6"])
        #expect(tree.mainLineTurnAndColors == [
            "1.white",
            "1.black",
            "2.white",
            "2.black",
            "3.white",
            "3.black"
        ])
        #expect(tree.variants.isEmpty)
    }

    @Test("Attach black variation to move node")
    func attachBlackVariation() async throws {
        let input =
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

        let game = try PGNGameParser().parse(input)
        let tree = try #require(game.moveTree)
        let mainLineLastMove = try #require(tree.mainLineLastNode)
        let variation = try #require(mainLineLastMove.variant)

        #expect(mainLineLastMove.turn == 5)
        #expect(mainLineLastMove.color == .black)
        #expect(mainLineLastMove.node.description == "Nf6")
        #expect(variation.mainLineDescriptions == ["Nd6", "Nxe5", "Be7", "Nxc6", "dxc6", "Bf1", "Bf5", "c3", "O-O", "d4", "Re8", "Nd2", "Nb5"])
        #expect(variation.mainLineTurnAndColors == [
            "5.black",
            "6.white",
            "6.black",
            "7.white",
            "7.black",
            "8.white",
            "8.black",
            "9.white",
            "9.black",
            "10.white",
            "10.black",
            "11.white",
            "11.black"
        ])
    }

    @Test("Attach multiple variations to the same move node")
    func attachMultipleVariations() async throws {
        let input =
        """
        [Event "MoveTree multiple variations"]
        [Site "Fischer-Core Test Collection"]
        [Result "*"]

        1. e4 (1. d4 d5) (1. Nf3 Nf6) e5 *
        """

        let game = try PGNGameParser().parse(input)
        let tree = try #require(game.moveTree)

        #expect(tree.node.description == "e4")
        #expect(tree.turn == 1)
        #expect(tree.color == .white)
        #expect(tree.next?.node.description == "e5")
        #expect(tree.next?.turn == 1)
        #expect(tree.next?.color == .black)
        #expect(tree.variants.count == 2)
        #expect(tree.variants.map(\.mainLineDescriptions) == [["d4", "d5"], ["Nf3", "Nf6"]])
        #expect(tree.variants.map(\.mainLineTurnAndColors) == [
            ["1.white", "1.black"],
            ["1.white", "1.black"]
        ])
    }

    @Test("Build move tree from PGN with several variations")
    func buildTreeFromPGNWithSeveralVariations() async throws {
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

        let game = try PGNGameParser().parse(input)
        let tree = try #require(game.moveTree)
        let mainLine = tree.mainLineNodes

        #expect(mainLine.count == 26)
        #expect(tree.maxDepth == 29)
        #expect(mainLine[0].turn == 1)
        #expect(mainLine[0].color == .white)
        #expect(mainLine[1].turn == 1)
        #expect(mainLine[1].color == .black)

        #expect(mainLine[3].node.description == "b6")
        #expect(mainLine[3].turn == 2)
        #expect(mainLine[3].color == .black)
        #expect(mainLine[3].variants.count == 1)
        #expect(mainLine[3].variants.first?.mainLineDescriptions == ["d5", "e3", "c5", "c3", "Nc6", "Nd2", "e6", "Ngf3", "Bd6", "Bg3", "O-O", "Bd3"])
        #expect(mainLine[3].variants.first?.mainLineTurnAndColors == [
            "2.black",
            "3.white",
            "3.black",
            "4.white",
            "4.black",
            "5.white",
            "5.black",
            "6.white",
            "6.black",
            "7.white",
            "7.black",
            "8.white"
        ])

        #expect(mainLine[8].node.description == "Bg5")
        #expect(mainLine[8].turn == 5)
        #expect(mainLine[8].color == .white)
        #expect(mainLine[8].variants.count == 1)

        #expect(mainLine[12].node.description == "Nfd2")
        #expect(mainLine[12].turn == 7)
        #expect(mainLine[12].color == .white)
        #expect(mainLine[12].variants.count == 2)
        #expect(mainLine[12].variants.map(\.mainLineDescriptions) == [
            ["Ne5", "Nf6", "Bg3", "d6", "Nc4", "Ne4"],
            ["Bg3", "Nxg3", "hxg3", "Bg7", "Nbd2", "e6", "c3", "d5", "a4", "a6"]
        ])
        #expect(mainLine[12].variants.map(\.mainLineTurnAndColors) == [
            ["7.white", "7.black", "8.white", "8.black", "9.white", "9.black"],
            ["7.white", "7.black", "8.white", "8.black", "9.white", "9.black", "10.white", "10.black", "11.white", "11.black"]
        ])

        #expect(mainLine[16].node.description == "Nf3")
        #expect(mainLine[16].turn == 9)
        #expect(mainLine[16].color == .white)
        #expect(mainLine[16].variants.count == 2)
        #expect(mainLine[16].variants.map(\.maxDepth) == [12, 4])
        #expect(mainLine[16].variants.map(\.mainLineTurnAndColors) == [
            ["9.white", "9.black", "10.white", "10.black", "11.white", "11.black", "12.white", "12.black", "13.white", "13.black", "14.white", "14.black"],
            ["9.white", "9.black", "10.white", "10.black"]
        ])
    }

    @Test("Build move tree from black-to-move PGN")
    func buildTreeFromBlackToMovePGN() async throws {
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

        let game = try PGNGameParser().parse(input)
        let tree = try #require(game.moveTree)
        let mainLine = tree.mainLineNodes

        #expect(mainLine.count == 10)
        #expect(tree.turn == 4)
        #expect(tree.color == .black)
        #expect(tree.node.description == "Nd7")
        #expect(tree.mainLineDescriptions == ["Nd7", "d4", "Ngf6", "Nxf6+", "Nxf6", "g3", "Be7", "Bg2", "O-O", "O-O"])
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
        #expect(tree.maxDepth == 15)

        #expect(mainLine[6].node.description == "Be7")
        #expect(mainLine[6].turn == 7)
        #expect(mainLine[6].color == .black)
        #expect(mainLine[6].variants.count == 2)
        #expect(mainLine[6].variants.map(\.mainLineDescriptions) == [
            ["c5", "Bg2"],
            ["b6", "Bg2", "Bb7", "O-O", "Be7", "Qe2", "O-O", "Rd1"]
        ])
        #expect(mainLine[6].variants.map(\.mainLineTurnAndColors) == [
            ["7.black", "8.white"],
            ["7.black", "8.white", "8.black", "9.white", "9.black", "10.white", "10.black", "11.white"]
        ])
    }

    @Test("Parse move tree directly from PGN text")
    func parseMoveTreeDirectlyFromPGNText() async throws {
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

        let expectedGame = try PGNGameParser().parse(input)
        let directPGN = try MoveTreePGNParser().parse(input)

        #expect(directPGN.tags == expectedGame.tags)
        #expect(directPGN.initialComment == expectedGame.initialComment)
        #expect(directPGN.result == expectedGame.result)
        #expect(directPGN.tree == expectedGame.moveTree)
    }

    @Test("Parse black-to-move tree directly from PGN text")
    func parseBlackToMoveTreeDirectlyFromPGNText() async throws {
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

        let pgn = try MoveTreePGNParser().parse(input)
        let tree = try #require(pgn.tree)

        #expect(pgn.tags[.fen] == "rnbqkbnr/ppp2ppp/4p3/8/4N3/5N2/PPPP1PPP/R1BQKB1R b KQkq - 0 4")
        #expect(pgn.result == .undefined)
        #expect(tree.turn == 4)
        #expect(tree.color == .black)
        #expect(tree.mainLineDescriptions == ["Nd7", "d4", "Ngf6", "Nxf6+", "Nxf6", "g3", "Be7", "Bg2", "O-O", "O-O"])
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
}

private extension MoveTree {
    var mainLineDescriptions: [String] {
        [node.description] + (next?.mainLineDescriptions ?? [])
    }

    var mainLineTurnAndColors: [String] {
        ["\(turn).\(color.rawValue)"] + (next?.mainLineTurnAndColors ?? [])
    }

    var mainLineNodes: [MoveTree] {
        [self] + (next?.mainLineNodes ?? [])
    }

    var mainLineLastNode: MoveTree? {
        next?.mainLineLastNode ?? self
    }

    var maxDepth: Int {
        let childDepth = max(
            next?.maxDepth ?? 0,
            variants.map(\.maxDepth).max() ?? 0
        )
        return 1 + childDepth
    }
}
