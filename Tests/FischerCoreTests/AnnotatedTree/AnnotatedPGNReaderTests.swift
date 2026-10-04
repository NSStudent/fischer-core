import Testing
@testable import FischerCore

struct AnnotatedPGNReaderTests {
    private func games() throws -> [AnnotatedPGNGame] {
        try PGNReader().parseAnnotated(TestResources.text("annotated-games"))
    }

    @Test("Reader keeps comments, NAGs and comment commands")
    func readsAnnotations() throws {
        let game = try #require(try games().first)
        #expect(game.issues.isEmpty)
        #expect(game.result == .win)
        #expect(game.tree.initialComments == ["The Italian game."])
        #expect(game.tree.initialAnnotations.squares == [
            PGNSquare(color: .green, square: .e4),
            PGNSquare(color: .red, square: .d5)
        ])

        let e4 = try #require(game.tree.node(at: [0]))
        #expect(e4.annotations.evaluation == "0.25")
        #expect(e4.annotations.parsedEvaluation == .pawns(0.25))
        #expect(e4.annotations.clock == "0:03:00")
        #expect(e4.annotations.clockSeconds == 180)

        let nf3 = try #require(game.tree.node(at: [0, 0, 0]))
        #expect(nf3.san.description == "Nf3")
        #expect(nf3.annotations.nags == [.goodMove])
        #expect(nf3.annotations.comments == ["Developing."])
        #expect(nf3.annotations.arrows == [
            PGNArrow(color: .green, fromSquare: .f3, toSquare: .e5),
            PGNArrow(color: .red, fromSquare: .b8, toSquare: .c6)
        ])

        let d5 = try #require(game.tree.mainline.first { $0.node.san.description == "d5" })
        #expect(d5.node.annotations.nags == [.speculativeMove])
        #expect(game.tree.mainline.last?.node.annotations.nags == [.whiteSlightAdvantage])
        #expect(game.tree.mainline.last?.node.annotations.comments == ["White is better."])
    }

    @Test("Reader builds variations with comments before their first move")
    func readsVariations() throws {
        let game = try #require(try games().first)
        let afterNf3 = game.tree.variations(after: [0, 0, 0])
        #expect(afterNf3.map(\.node.san.description) == ["d6", "Nf6"])
        #expect(afterNf3[0].node.annotations.comments == ["Philidor"])
        #expect(afterNf3[1].node.annotations.commentsBefore == ["Petrov:"])
        // Nested variation 3... Nf6 inside 2... d6
        let nested = game.tree.variations(after: [0, 0, 0, 1, 0])
        #expect(nested.map(\.node.numberedSAN) == ["3... Nf6"])
        #expect(game.tree.sanLine(through: nested[0].path).map(\.description) == ["e4", "e5", "Nf3", "d6", "d4", "Nf6"])
        #expect(game.tree.fen(at: nested[0].path) == "rnbqkb1r/ppp2ppp/3p1n2/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R w KQkq - 1 4")
    }

    @Test("Reader canonicalizes SAN and keeps numbering for black-to-move starts")
    func canonicalSANAndNumbering() throws {
        let all = try games()
        let endgame = all[1]
        let first = try #require(endgame.tree.node(at: [0]))
        #expect(first.numberedSAN == "50... b1=N+")
        #expect(first.annotations.comments == ["Underpromotion with check."])
        #expect(endgame.tree.node(at: [1])?.san.description == "b1=Q")
        #expect(endgame.tree.node(at: [1])?.annotations.nags == [.poorMove])
        #expect(endgame.tree.node(at: [0, 0])?.numberedSAN == "51. Kb3")
        #expect(endgame.tree.node(at: [0, 0, 0])?.numberedSAN == "51... Kd7")

        let castling = all[2]
        #expect(castling.tree.node(at: [0])?.san.description == "O-O+")
    }

    @Test("Reader keeps unknown NAG codes and comment commands, accepts zero castling")
    func readsChessBaseExtras() throws {
        let game = try games()[3]
        #expect(game.issues.isEmpty)
        #expect(game.result == .draw)
        let castle = try #require(game.tree.mainline.first { $0.node.moveNumber == 7 && $0.node.color == .white })
        #expect(castle.node.san.description == "O-O")
        #expect(castle.node.annotations.nags == [.speculativeMove])
        #expect(castle.node.annotations.otherNAGCodes == [146])
        #expect(castle.node.annotations.otherCommands == [PGNCommentCommand(name: "mdl", value: "8192")])
        #expect(castle.node.annotations.comments == ["A novelty"])
        #expect(game.tags[.whiteElo] == "2500")
        #expect(game.tagOrder.prefix(3) == [.event, .site, .date])
    }

    @Test("Lenient reading drops an illegal move and its line, strict reading throws")
    func illegalMoves() throws {
        let pgn = """
        [Event "Broken"]

        1. e4 e5 2. Nf3 ( 2. Ke3 ) 2... d6 3. Bb5+ Nf6 4. O-O *
        """
        let game = try AnnotatedPGNGame(pgn: pgn)
        let issues = game.issues.sorted { $0.san < $1.san }
        #expect(issues == [
            PGNReadIssue(path: [0, 0], san: "Ke3", reason: .notFound),
            PGNReadIssue(path: [0, 0, 0, 0, 0], san: "Nf6", reason: .illegal)
        ])
        #expect(game.tree.mainline.map(\.node.san.description) == ["e4", "e5", "Nf3", "d6", "Bb5+"])
        #expect(throws: AnnotatedPGNError.self) {
            _ = try AnnotatedPGNGame(pgn: pgn, strict: true)
        }
    }

    @Test("Reader handles games without tags, glued annotations and lenient tokens")
    func readsLooseMovetext() throws {
        let game = try AnnotatedPGNGame(pgn: "1. e4!! e5?! 2. Qh5 Nc6 3. Bc4 Nf6?? 4. Qxf7# 1-0")
        #expect(game.tags.isEmpty)
        #expect(game.tree.node(at: [0])?.annotations.nags == [.veryGoodMove])
        #expect(game.tree.node(at: [0, 0])?.annotations.nags == [.questionableMove])
        #expect(game.tree.mainline.last?.node.san.description == "Qxf7#")
        #expect(game.result == .win)

        let promotion = try AnnotatedPGNGame(pgn: """
        [FEN "8/4P3/8/8/8/k7/8/K7 w - - 0 1"]

        1. e8Q Kb3 *
        """)
        #expect(promotion.issues.isEmpty)
        #expect(promotion.tree.node(at: [0])?.san.description == "e8=Q")
    }

    @Test("Reader rejects an invalid FEN tag")
    func invalidFEN() {
        #expect(throws: AnnotatedPGNError.invalidFEN("not a fen")) {
            _ = try AnnotatedPGNGame(pgn: "[FEN \"not a fen\"]\n\n1. e4 *")
        }
        #expect(throws: AnnotatedPGNError.noGame) {
            _ = try AnnotatedPGNGame(pgn: "   ")
        }
    }

    @Test("Reader does not hang on an unterminated comment")
    func unterminatedComment() throws {
        let game = try AnnotatedPGNGame(pgn: "1. e4 { never closed")
        #expect(game.tree.node(at: [0])?.annotations.comments == ["never closed"])
        var reader = MoveTreePGNReader("[Event \"x\"]\n\n1. e4 { open")
        let read = try reader.readGame()
        #expect(read?.tree?.node.description == "e4")
    }

    @Test("Annotated main line matches the MoveTree reader on real games")
    func mainlineMatchesMoveTreeReader() throws {
        let text = try TestResources.text("wcup25-short")
        let annotated = try PGNReader().parseAnnotated(text)
        let plain = try PGNReader().parse(text)
        #expect(annotated.count == plain.count)
        for (lhs, rhs) in zip(annotated, plain) {
            #expect(lhs.issues.isEmpty)
            var sans: [String] = []
            var node = rhs.tree
            while let current = node {
                sans.append(current.node.description)
                node = current.next
            }
            #expect(lhs.tree.mainline.map(\.node.san.description) == sans)
        }
    }

    @Test("Converting a MoveTreePGN resolves moves and variations")
    func convertsMoveTreePGN() throws {
        var reader = MoveTreePGNReader("[Event \"x\"]\n\n{ Intro } 1. e4 e5 ( 1... c5 2. Nf3 ) 2. Nf3 *")
        let pgn = try #require(try reader.readGame())
        let game = try AnnotatedPGNGame(pgn)
        #expect(game.tree.initialComments == ["Intro"])
        #expect(game.tree.variations(after: [0]).map(\.node.san.description) == ["c5"])
        #expect(game.tree.mainline.count == 3)
    }
}

struct AnnotatedPGNConversionTests {
    @Test("Converting a PGNGame keeps comments, NAGs and variations like the reader")
    func convertsPGNGame() throws {
        let text = """
        [Event "Conversion"]
        [Result "*"]

        { Intro } 1. e4 { [%clk 0:05:00] } e5 { [%clk 0:05:00] } 2. Nf3 $1 { Developing } ( 2. Bc4 ) 2... Nc6 ( 2... d6 3. d4 ) 3. Bb5 *
        """
        let parsed = try PGNGameParser().parse(text)
        let converted = try AnnotatedPGNGame(parsed)
        let read = try AnnotatedPGNGame(pgn: text)
        #expect(converted.issues.isEmpty)
        #expect(converted.tree == read.tree)
        #expect(converted.tree.clocks(at: [0, 0]) == PGNClockSnapshot(white: 300, black: 300))
        #expect(converted.tree.clocks(at: [0]) == PGNClockSnapshot(white: 300, black: nil))
    }
}
