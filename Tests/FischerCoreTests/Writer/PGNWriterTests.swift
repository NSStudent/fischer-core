import Testing
@testable import FischerCore

struct PGNWriterTests {
    @Test("Black moves get their number after a comment or a variation")
    func blackMoveNumberAfterCommentAndVariation() throws {
        var tree = AnnotatedMoveTree()
        let e4 = try tree.insert(san: "e4", at: .root)
        let e5 = try tree.insert(san: "e5", at: e4)
        _ = try tree.insert(san: "c5", at: e4)
        let nf3 = try tree.insert(san: "Nf3", at: e5)
        let nc6 = try tree.insert(san: "Nc6", at: nf3)
        let bb5 = try tree.insert(san: "Bb5", at: nc6)
        _ = try tree.insert(san: "a6", at: bb5)
        tree.updateAnnotations(at: nf3) { $0.comments = ["Developing"] }

        let movetext = PGNWriter(options: .compact).movetext(tree, result: .undefined)
        #expect(movetext == "1. e4 e5 (1... c5) 2. Nf3 { Developing } 2... Nc6 3. Bb5 a6 *")
    }

    @Test("Black move gets its number after a variation on the white move")
    func blackMoveNumberAfterWhiteVariation() throws {
        var tree = AnnotatedMoveTree()
        tree.insertLine(uci: ["e2e4", "e7e5", "g1f3", "b8c6"], at: .root)
        tree.insertLine(uci: ["f2f4", "e5f4"], at: [0, 0])
        let movetext = PGNWriter(options: .compact).movetext(tree, result: nil)
        #expect(movetext == "1. e4 e5 2. Nf3 (2. f4 exf4) 2... Nc6")
    }

    @Test("Variation starting with a black move and nested variations")
    func nestedVariations() throws {
        let game = try AnnotatedPGNGame(pgn: "1. e4 e5 (1... c5 2. Nf3 (2. c3 d5) 2... d6) 2. Nf3 *")
        let movetext = PGNWriter(options: .compact).movetext(game.tree, result: game.result)
        #expect(movetext == "1. e4 e5 (1... c5 2. Nf3 (2. c3 d5) 2... d6) 2. Nf3 *")
    }

    @Test("Comments, NAGs and commands are written in a readable order")
    func annotationsAreWritten() throws {
        var tree = AnnotatedMoveTree()
        let e4 = try tree.insert(san: "e4", at: .root)
        tree.initialComments = ["Start"]
        tree.updateAnnotations(at: e4) {
            $0.nags = [.goodMove, .whiteSlightAdvantage]
            $0.otherNAGCodes = [146]
            $0.comments = ["Main idea {braces}", "Second"]
            $0.evaluation = "0.30"
            $0.clock = "0:10:00"
            $0.squares = [PGNSquare(color: .green, square: .e4)]
            $0.arrows = [PGNArrow(color: .red, fromSquare: .d7, toSquare: .d5)]
            $0.otherCommands = [PGNCommentCommand(name: "mdl", value: "8")]
        }
        let numeric = PGNWriter(options: .compact).movetext(tree, result: .undefined)
        #expect(numeric == "{ Start } 1. e4 $1 $14 $146 { [%eval 0.30] [%clk 0:10:00] [%csl Ge4] [%cal Rd7d5] [%mdl 8] Main idea (braces) } { Second } *")

        var symbolicOptions = PGNWriter.Options.compact
        symbolicOptions.nagStyle = .symbolic
        symbolicOptions.includeCommands = false
        let symbolic = PGNWriter(options: symbolicOptions).movetext(tree, result: nil)
        #expect(symbolic == "{ Start } 1. e4! $14 $146 { Main idea (braces) } { Second }")

        let plain = PGNWriter(options: .mainlineOnly).movetext(tree, result: nil)
        #expect(plain == "1. e4")
    }

    @Test("Spanish output for display")
    func spanishOutput() throws {
        var options = PGNWriter.Options.compact
        options.language = .spanish
        let game = try Game(sanMoves: ["e4", "e5", "Nf3", "Nc6", "Bb5"])
        let tree = AnnotatedMoveTree(game: game)
        #expect(PGNWriter(options: options).movetext(tree, result: nil) == "1. e4 e5 2. Cf3 Cc6 3. Ab5")
        #expect(PGNWriter().line(tree, through: [0, 0, 0]) == "1. e4 e5 2. Nf3")
        #expect(PGNWriter().line(tree, through: [0, 0, 0, 0]) == "1. e4 e5 2. Nf3 Nc6")
    }

    @Test("Seven tag roster, defaults and tag order")
    func tagSection() {
        let section = PGNWriter().tagSection(
            [.white: "Carlsen, Magnus", .custom("Zeta"): "z", .eco: "B90", .event: "Quote \"test\""],
            order: [.eco]
        )
        #expect(section == """
        [Event "Quote \\"test\\""]
        [Site "?"]
        [Date "????.??.??"]
        [Round "?"]
        [White "Carlsen, Magnus"]
        [Black "?"]
        [Result "*"]
        [ECO "B90"]
        [Zeta "z"]
        """)
        #expect(PGNTag.sevenTagRoster.map(\.rawValue) == ["Event", "Site", "Date", "Round", "White", "Black", "Result"])
    }

    @Test("Game.pgn writes FEN, SetUp and result")
    func gamePGN() throws {
        let game = try Game(initialFEN: "4k3/8/8/8/8/K7/1p6/8 b - - 0 50", sanMoves: ["b1=N", "Kb3"])
        let pgn = game.pgn(tags: [.event: "Lesson"])
        #expect(pgn.contains("[FEN \"4k3/8/8/8/8/K7/1p6/8 b - - 0 50\"]"))
        #expect(pgn.contains("[SetUp \"1\"]"))
        #expect(pgn.hasSuffix("\n\n50... b1=N+ 51. Kb3 *\n"))

        let mate = try Game(sanMoves: ["f3", "e5", "g4", "Qh4"])
        let matePGN = mate.pgn()
        #expect(matePGN.contains("[Result \"0-1\"]"))
        #expect(matePGN.hasSuffix("1. f3 e5 2. g4 Qh4# 0-1\n"))
        #expect(!matePGN.contains("[FEN"))

        let draw = Game().pgn(result: .draw)
        #expect(draw.hasSuffix("\n\n1/2-1/2\n"))
    }

    @Test("Lines are wrapped at 80 characters and never start with [ or %")
    func lineWrapping() throws {
        let text = try TestResources.text("annotated-games")
        let games = try PGNReader().parseAnnotated(text)
        for game in games {
            let output = PGNWriter().write(game)
            let movetext = output.components(separatedBy: "\n\n").dropFirst().joined(separator: "\n\n")
            for line in movetext.split(separator: "\n") {
                #expect(line.count <= 80)
                #expect(!line.hasPrefix("["))
                #expect(!line.hasPrefix("%"))
            }
        }
    }

    @Test("Round trip of the annotated fixture keeps the tree")
    func annotatedRoundTrip() throws {
        try assertRoundTrip(TestResources.text("annotated-games"), expectedGames: 4)
    }

    @Test("Round trip of real tournament PGNs", arguments: ["wcup25-short", "twic1617-short", "twic1618-short"])
    func realPGNRoundTrip(resource: String) throws {
        try assertRoundTrip(TestResources.text(resource), expectedGames: nil)
    }

    private func assertRoundTrip(_ text: String, expectedGames: Int?) throws {
        let original = try PGNReader().parseAnnotated(text)
        if let expectedGames {
            #expect(original.count == expectedGames)
        }
        let written = PGNWriter().write(original)
        let reread = try PGNReader().parseAnnotated(written)
        #expect(reread.count == original.count)
        for (lhs, rhs) in zip(original, reread) {
            #expect(lhs.issues.isEmpty)
            #expect(lhs.tree == rhs.tree)
            #expect(lhs.result == rhs.result)
            #expect(lhs.tags.filter { $0.value != "" } == rhs.tags.filter { $0.value != "" } || lhs.tags.count < rhs.tags.count)
        }
        // Writing is stable once normalized.
        #expect(PGNWriter().write(reread) == written)
    }
}
