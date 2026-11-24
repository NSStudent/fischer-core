import Testing
@testable import FischerCore

struct NullMoveTests {
    // MARK: - SAN

    @Test("`--` is read as the null move in strict and lenient SAN")
    func parsesDoubleDash() throws {
        #expect(try SANMove(san: "--") == .nullMove)
        #expect(try SANMove(san: "--", options: .strict) == .nullMove)
        #expect(try SANMove(san: "--", options: .lenient) == .nullMove)
    }

    @Test("Other null move spellings are only read in lenient SAN", arguments: ["Z0", "0000", "@@@@"])
    func parsesOtherSpellingsLeniently(token: String) throws {
        #expect(try SANMove(san: token, options: .lenient) == .nullMove)
        #expect(throws: (any Error).self) { try SANMove(san: token, options: .strict) }
    }

    @Test("The null move is written as `--` and has no check, capture or castling flags")
    func describesNullMove() {
        let move = SANMove.nullMove
        #expect(move.description == "--")
        #expect(move.description(language: .spanish) == "--")
        #expect(move.isNullMove)
        #expect(!move.isCheck && !move.isCheckmate && !move.isCapture && !move.isCastling)
        #expect(move.promotion == nil)
        #expect(move.withCheckFlags(isCheck: true, isCheckmate: false) == .nullMove)
    }

    // MARK: - Game

    @Test("A null move passes the turn and keeps the board")
    func executesNullMove() throws {
        var game = Game()
        try game.execute(uci: "e2e4")
        try game.executeNullMove()

        #expect(game.position.fen() == "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 1 2")
        #expect(game.playerTurn == .white)
        #expect(game.enPassantTarget == nil)
        #expect(game.moveHistory.isEmpty)
        #expect(game.initialFen == game.position.fen())

        try game.execute(uci: "d2d4")
        #expect(game.position.fen() == "rnbqkbnr/pppppppp/8/8/3PP3/8/PPP2PPP/RNBQKBNR b KQkq d3 0 2")
    }

    @Test("A white null move keeps the fullmove number")
    func whiteNullMoveKeepsFullmoves() throws {
        var game = Game()
        try game.executeNullMove()
        #expect(game.position.fen() == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 1 1")
    }

    @Test("A null move keeps piece identities")
    func keepsPieceIdentities() throws {
        var game = Game()
        try game.execute(uci: "g1f3")
        let before = Square.allCases.map(game.pieceID(at:))
        try game.executeNullMove()
        #expect(Square.allCases.map(game.pieceID(at:)) == before)
    }

    @Test("A null move is not allowed in check")
    func rejectsNullMoveInCheck() throws {
        var game = Game()
        for uci in ["e2e4", "f7f6", "d1h5"] {
            try game.execute(uci: uci)
        }
        #expect(!game.canPlayNullMove)
        #expect(!game.isLegal(move: .null))
        #expect(throws: Game.ExecutionError.self) { try game.executeNullMove() }
        #expect(game.resolveResult(.nullMove) == .failure(.illegal))
    }

    @Test("Executing Move.null or ResolvedMove.null plays a null move")
    func executesNullThroughMoveAPIs() throws {
        var viaMove = Game()
        try viaMove.execute(move: .null)
        var viaResolved = Game()
        try viaResolved.execute(resolvedMove: .null)
        var viaNull = Game()
        try viaNull.executeNullMove()

        #expect(viaMove.position == viaNull.position)
        #expect(viaResolved.position == viaNull.position)
    }

    @Test("SAN resolution and generation handle the null move")
    func resolvesNullMove() throws {
        let game = Game()
        #expect(game.candidates(for: .nullMove) == [.null])
        #expect(game.resolveResult(.nullMove) == .success(.null))
        #expect(game.resolveResult(.nullMove, strict: true) == .success(.null))
        #expect(game.resolveResult(san: "--") == .success(.null))
        #expect(try game.san(for: .null) == .nullMove)
        #expect(try game.longNotation(for: .null) == "--")
        #expect(try Move(game: game, sanMove: .nullMove) == .null)
        #expect(ResolvedMove.null.uci == "0000")
        #expect(ResolvedMove.null.isNull)
        #expect(!ResolvedMove(move: .e2 >>> .e4).isNull)
    }

    // MARK: - Reading

    @Test("Variations of a null move are alternatives from the same position")
    func readsVariationsOfNullMove() throws {
        let game = try AnnotatedPGNGame(
            pgn: "1. e4 e5 2. Nf3 -- (2... Nc6 3. Bb5) (2... Nf6) 3. Bc4 *",
            strict: true
        )
        #expect(game.issues.isEmpty)
        #expect(game.tree.sanLine(through: [0, 0, 0, 0, 0]).map(\.description) == ["e4", "e5", "Nf3", "--", "Bc4"])

        let null = try #require(game.tree.node(at: [0, 0, 0, 0]))
        #expect(null.san == .nullMove)
        #expect(null.move.isNull)
        #expect(null.color == .black)
        #expect(null.moveNumber == 2)

        let alternatives = game.tree.children(at: [0, 0, 0])
        #expect(alternatives.map(\.san.description) == ["--", "Nc6", "Nf6"])
        #expect(alternatives.allSatisfy { $0.color == .black && $0.moveNumber == 2 })
        #expect(game.tree.node(at: [0, 0, 0, 1, 0])?.san.description == "Bb5")

        let bc4 = try #require(game.tree.node(at: [0, 0, 0, 0, 0]))
        #expect(bc4.color == .white)
        #expect(bc4.moveNumber == 3)
    }

    @Test("Every null move spelling is read from movetext")
    func readsAllSpellings() throws {
        let game = try AnnotatedPGNGame(pgn: "1. e4 Z0 2. d4 0000 3. c4 @@@@ 4. Nc3 -- *", strict: true)
        #expect(game.issues.isEmpty)
        #expect(game.tree.mainline.map(\.node.san.description) == ["e4", "--", "d4", "--", "c4", "--", "Nc3", "--"])
    }

    @Test("A null move glued to a variation or comment is read")
    func readsNullMoveBeforeDelimiters() throws {
        let game = try AnnotatedPGNGame(pgn: "1. e4 --(1... e5){Passing.} 2. d4 *", strict: true)
        #expect(game.issues.isEmpty)
        #expect(game.tree.children(at: [0]).map(\.san.description) == ["--", "e5"])
        #expect(game.tree.node(at: [0, 0])?.annotations.comments == ["Passing."])
    }

    @Test("A null move in check is an issue in lenient mode and an error in strict mode")
    func reportsNullMoveInCheck() throws {
        let pgn = "1. e4 f6 2. Qh5+ -- 3. Qxe8 *"
        let lenient = try AnnotatedPGNGame(pgn: pgn)
        #expect(lenient.issues.map(\.san) == ["--"])
        #expect(lenient.issues.first?.reason == .illegal)
        #expect(lenient.tree.mainline.count == 3)

        #expect(throws: AnnotatedPGNError.self) { try AnnotatedPGNGame(pgn: pgn, strict: true) }
    }

    @Test("The raw reader keeps null moves in MoveTree")
    func rawReaderKeepsNullMoves() throws {
        let game = try #require(try PGNReader().parse("1. e4 -- (1... e5) 2. d4 *").first)
        let tree = try #require(game.tree)
        #expect(tree.next?.node == .nullMove)
        #expect(tree.next?.variants.first?.node.description == "e5")
        #expect(tree.next?.next?.node.description == "d4")
    }

    // MARK: - Tree and writer

    @Test("Positions after a null move are computed through the tree")
    func computesPositionsThroughNullMove() throws {
        let game = try AnnotatedPGNGame(pgn: "1. e4 -- 2. d4 *", strict: true)
        #expect(game.tree.fen(at: [0, 0]) == "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 1 2")
        #expect(game.tree.fen(at: [0, 0, 0]) == "rnbqkbnr/pppppppp/8/8/3PP3/8/PPP2PPP/RNBQKBNR b KQkq d3 0 2")
        #expect(game.tree.uciLine(through: [0, 0, 0]) == ["e2e4", "0000", "d2d4"])
    }

    @Test("A null move can be inserted in the tree")
    func insertsNullMove() throws {
        var tree = AnnotatedMoveTree()
        let e4 = try tree.insert(san: "e4", at: .root)
        let null = try tree.insert(.null, at: e4)
        #expect(tree.node(at: null)?.san == .nullMove)
        #expect(try tree.insert(san: "--", at: e4) == null)
        let d4 = try tree.insert(san: "d4", at: null)
        #expect(tree.node(at: d4)?.color == .white)
    }

    @Test("The writer writes `--` and the game reads back the same")
    func roundTripsNullMoves() throws {
        let pgn = "1. e4 e5 2. Nf3 -- (2... Nc6 3. Bb5) (2... Nf6) 3. Bc4 *"
        let game = try AnnotatedPGNGame(pgn: pgn, strict: true)
        let written = game.pgn()
        #expect(written.contains("2. Nf3 -- (2... Nc6 3. Bb5) (2... Nf6) 3. Bc4"))

        let reread = try AnnotatedPGNGame(pgn: written, strict: true)
        #expect(reread.tree == game.tree)
    }

    // MARK: - Annotated book game

    /// The moves of Kasparov–Karpov, game 48 of the 1984/85 World
    /// Championship match, with the null moves an annotated edition uses to
    /// list several replies from one position. Comments are placeholders.
    static let annotatedBookGame = """
    [Event "World Championship Match"]
    [Site "Moscow"]
    [Date "1985.02.08"]
    [Round "48"]
    [White "Kasparov, G."]
    [Black "Karpov, A."]
    [Result "1-0"]

    1. e4 e5 2. Nf3 Nf6 3. Nxe5 d6 4. Nf3 Nxe4 5. d4 d5 6. Bd3 Nc6 7. O-O Be7
    8. c4 Nf6 9. Nc3 O-O 10. h3 dxc4 11. Bxc4 Na5 12. Bd3 Be6 13. Re1 Nc6 14. a3
    a6 15. Bf4 Qd7 (15... Nd5 16. Bg3 {Two replies:} -- ({first} 16... Bf6 17. Ne4
    $1 Bxd4 18. Neg5 Bxb2 (18... Nf6 19. Rxe6) 19. Rb1) ({second} 16... Bd6 17. Bh4
    Be7 18. Bxe7 Ncxe7 (18... Ndxe7 19. Rxe6 $1 fxe6 20. Ng5) 19. Ng5 Bf5 20. Nxd5
    Nxd5 21. Bxf5 Qxg5 22. Re5 $1 Qd8 23. Bxh7+ Kxh7 24. Qh5+)) 16. Ne5 Nxe5 17.
    dxe5 Nd5 18. Nxd5 Bxd5 19. Qc2 g6 (19... h6 20. Rac1 $1 -- (20... c6 21. Re3)
    (20... c5 21. Qe2 -- (21... Rfd8 22. Bb1 Bf8 23. Rc3) (21... Qe6 22. Bb1 c4)))
    20. Rad1 c6 21. Bh6 Rfd8 22. e6 fxe6 23. Bxg6 Bf8 24. Bxf8 Rxf8 25. Be4 Rf7
    26. Re3 Rg7 27. Rdd3 Rf8 28. Rg3 Kh8 29. Qc3 Rff7 (29... Rf4 30. -- (30. Rg5
    Rff7 31. Re3 Kg8) (30. Bxd5 exd5 31. Qe5 Rf8)) 30. Rde3 1-0
    """

    @Test("The annotated book game reads with its null moves and no issues")
    func readsAnnotatedBookGame() throws {
        let game = try AnnotatedPGNGame(pgn: Self.annotatedBookGame, strict: true)
        #expect(game.issues.isEmpty)
        #expect(game.result == .win)
        #expect(game.tree.mainline.last?.node.numberedSAN == "30. Rde3")

        // 15... Nd5 16. Bg3 -- with 16... Bf6 and 16... Bd6 as alternatives.
        let nd5 = MovePath.mainline(plies: 29).appending(1)
        #expect(game.tree.node(at: nd5)?.numberedSAN == "15... Nd5")
        let replies = game.tree.children(at: nd5.appending(0))
        #expect(replies.map(\.numberedSAN) == ["16... --", "16... Bf6", "16... Bd6"])
        #expect(replies[0].annotations.commentsBefore == [])
        #expect(replies[1].annotations.commentsBefore == ["first"])
        #expect(game.tree.node(at: nd5.appending(0))?.annotations.comments == ["Two replies:"])

        // 29... Rf4 30. -- with 30. Rg5 and 30. Bxd5 as alternatives.
        let rf4 = MovePath.mainline(plies: 57).appending(1)
        #expect(game.tree.node(at: rf4)?.numberedSAN == "29... Rf4")
        #expect(game.tree.children(at: rf4).map(\.numberedSAN) == ["30. --", "30. Rg5", "30. Bxd5"])

        let reread = try AnnotatedPGNGame(pgn: game.pgn(), strict: true)
        #expect(reread.tree == game.tree)
    }
}
