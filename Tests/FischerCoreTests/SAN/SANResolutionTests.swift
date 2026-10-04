import Testing
@testable import FischerCore

struct SANResolutionTests {
    // MARK: - Castling description

    @Test("Castling SAN keeps check and mate markers")
    func castlingDescriptionKeepsMarkers() {
        #expect(SANMove.kingsideCastling(isCheck: true, isCheckMate: false).description == "O-O+")
        #expect(SANMove.queensideCastling(isCheck: false, isCheckMate: true).description == "O-O-O#")
        #expect(SANMove.kingsideCastling(isCheck: false, isCheckMate: false).description == "O-O")
    }

    @Test("Castling that gives check is generated with +")
    func castlingWithCheckFromPosition() throws {
        let game = try Game(with: "5k2/8/8/8/8/8/8/4K2R w K - 0 1")
        let san = try game.san(for: ResolvedMove(move: .e1 >>> .g1))
        #expect(san.description == "O-O+")
        #expect(try game.sanMove(from: "e1g1").description == "O-O+")
    }

    // MARK: - Underpromotion

    @Test("Check after underpromotion uses the actual promotion piece")
    func checkAfterUnderpromotion() throws {
        // A knight on c8 checks the king on e7; a queen on c8 would not.
        let game = try Game(with: "8/2P1k3/8/8/8/8/8/K7 w - - 0 1")
        #expect(try game.sanMove(from: "c7c8n").description == "c8=N+")
        #expect(try game.sanMove(from: "c7c8q").description == "c8=Q")
        #expect(try game.sanMoveList(from: ["c7c8n", "e7e6"]).map(\.description) == ["c8=N+", "Ke6"])
    }

    @Test("Promotion without a piece defaults to queen in lenient mode and fails in strict mode")
    func missingPromotion() throws {
        let game = try Game(with: "8/4P3/8/8/8/k7/8/K7 w - - 0 1")
        let lenient = try game.resolve(san: "e8")
        #expect(lenient == ResolvedMove(move: .e7 >>> .e8, promotion: .queen))
        #expect(game.resolveResult(san: "e8", strict: true) == .failure(.missingPromotion))
        #expect(try game.resolve(san: "e8=N") == ResolvedMove(move: .e7 >>> .e8, promotion: .knight))
        #expect(game.candidates(for: try SANMove(san: "e8")).count == 4)
    }

    @Test("Unexpected promotion is ignored leniently and reported strictly")
    func unexpectedPromotion() throws {
        let game = Game()
        #expect(try game.resolve(san: "e4=Q") == ResolvedMove(move: .e2 >>> .e4))
        #expect(game.resolveResult(san: "e4=Q", strict: true) == .failure(.unexpectedPromotion))
    }

    // MARK: - Ambiguity, illegal and not found

    @Test("Ambiguous SAN is reported with its candidates")
    func ambiguousSAN() throws {
        let game = try Game(with: "4k3/8/8/8/8/8/8/2N1K1N1 w - - 0 1")
        let result = game.resolveResult(san: "Ne2")
        guard case let .failure(.ambiguous(candidates)) = result else {
            Issue.record("Expected ambiguity, got \(result)")
            return
        }
        #expect(Set(candidates.map(\.move.start)) == [.c1, .g1])
        #expect(try game.resolve(san: "Nge2") == ResolvedMove(move: .g1 >>> .e2))
        #expect(try game.san(for: ResolvedMove(move: .c1 >>> .e2)).description == "Nce2")
        // The 0.3.1 API keeps picking the first legal candidate.
        #expect(try Move(game: game, sanMove: SANMove(san: "Ne2")).end == .e2)
    }

    @Test("Knights on the same file disambiguate by rank")
    func ambiguityByRank() throws {
        let game = try Game(with: "4k3/8/8/8/8/N7/8/N3K3 w - - 0 1")
        #expect(game.resolveResult(san: "Nc2").isAmbiguous)
        #expect(try game.resolve(san: "N1c2") == ResolvedMove(move: .a1 >>> .c2))
        #expect(try game.san(for: ResolvedMove(move: .a3 >>> .c2)).description == "N3c2")
    }

    @Test("Three queens need full square disambiguation")
    func ambiguityBySquare() throws {
        let game = try Game(with: "1k6/8/8/8/4Q2Q/8/8/K6Q w - - 0 1")
        #expect(try game.san(for: ResolvedMove(move: .h4 >>> .e1)).description == "Qh4e1")
        #expect(try game.resolve(san: "Qh4e1") == ResolvedMove(move: .h4 >>> .e1))
    }

    @Test("Pinned piece move is illegal and missing piece is not found")
    func illegalAndNotFound() throws {
        // The knight on d2 is pinned by the bishop on b4.
        let game = try Game(with: "4k3/8/8/8/1b6/8/3N4/4K3 w - - 0 1")
        #expect(game.resolveResult(san: "Nf3") == .failure(.illegal))
        #expect(game.resolveResult(san: "Qd4") == .failure(.notFound))
        #expect(game.resolveResult(san: "zz9") == .failure(.invalidNotation("zz9")))
    }

    @Test("Strict mode reports capture and check mismatches")
    func strictMismatches() throws {
        var game = Game()
        try game.execute(san: "e4")
        try game.execute(san: "d5")
        #expect(game.resolveResult(san: "Nf3+", strict: true) == .failure(.checkMismatch))
        #expect(try game.resolve(san: "Nf3+") == ResolvedMove(move: .g1 >>> .f3))
        #expect(game.resolveResult(san: "Bb5+", strict: true).isSuccess)
        #expect(game.resolveResult(san: "Bb5", strict: true) == .failure(.checkMismatch))
        #expect(game.resolveResult(san: "e4d5", strict: true) == .failure(.invalidNotation("e4d5")) || game.resolveResult(san: "e4d5", strict: true).isSuccess)
        #expect(game.resolveResult(san: "exd5", strict: true).isSuccess)
        #expect(game.resolveResult(san: "Nxf3", strict: true) == .failure(.captureMismatch))
        #expect(try game.resolve(san: "Nxf3") == ResolvedMove(move: .g1 >>> .f3))
    }

    // MARK: - Lenient parsing

    @Test("Lenient parsing accepts zero castling, glued annotations and missing symbols")
    func lenientParsing() throws {
        #expect(try SANMove(san: "0-0", options: .lenient) == .kingsideCastling(isCheck: false, isCheckMate: false))
        #expect(try SANMove(san: "0-0-0+", options: .lenient) == .queensideCastling(isCheck: true, isCheckMate: false))
        #expect(try SANMove(san: "Nf3!?", options: .lenient).description == "Nf3")
        #expect(try SANMove(san: "Qxf7#!!", options: .lenient).description == "Qxf7#")
        #expect(try SANMove(san: "e4$1", options: .lenient).description == "e4")
        #expect(try SANMove(san: "exd6e.p.", options: .lenient).description == "exd6")
        #expect(try SANMove(san: "e8Q", options: .lenient).description == "e8=Q")
        #expect(try SANMove(san: "e8(N)+", options: .lenient).description == "e8=N+")
        #expect(try SANMove(san: "Qh7++", options: .lenient).description == "Qh7#")
        #expect(try SANMove(san: "♘f3", options: .lenient).description == "Nf3")
        #expect(throws: (any Error).self) { try SANMove(san: "0-0") }
        #expect(throws: (any Error).self) { try SANMove(san: "Nf3!") }
    }

    @Test("Resolving castling written with zeros and without check marker")
    func resolveZeroCastling() throws {
        let game = try Game(with: "5k2/8/8/8/8/8/8/4K2R w K - 0 1")
        #expect(try game.resolve(san: "0-0") == ResolvedMove(move: .e1 >>> .g1))
        #expect(game.resolveResult(san: "0-0", strict: true) == .failure(.invalidNotation("0-0")))
        #expect(game.resolveResult(san: "O-O", strict: true) == .failure(.checkMismatch))
        #expect(game.resolveResult(san: "O-O+", strict: true).isSuccess)
        #expect(game.resolveResult(san: "O-O-O") == .failure(.illegal))
    }

    @Test("King-takes-rook UCI castling is normalized")
    func kingTakesRookCastling() throws {
        var game = try Game(with: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
        #expect(game.resolvedMove(uci: "e1h1") == ResolvedMove(move: .e1 >>> .g1))
        #expect(game.resolvedMove(uci: "e1a1") == ResolvedMove(move: .e1 >>> .c1))
        try game.execute(uci: "e1h1")
        #expect(game.board[.g1] == Piece(king: .white))
        #expect(game.board[.f1] == Piece(rook: .white))
        #expect(try game.sanMove(from: "e8a8").description == "O-O-O")
    }

    // MARK: - Spanish

    @Test("Spanish SAN translates to English and back")
    func spanishTranslation() throws {
        let spanish = SANNotationLanguage.spanish
        #expect(spanish.translateToEnglish("Cf3") == "Nf3")
        #expect(spanish.translateToEnglish("Axb5+") == "Bxb5+")
        #expect(spanish.translateToEnglish("Tad1") == "Rad1")
        #expect(spanish.translateToEnglish("Dxd8#") == "Qxd8#")
        #expect(spanish.translateToEnglish("Re2") == "Ke2")
        #expect(spanish.translateToEnglish("e8=D") == "e8=Q")
        #expect(spanish.translateToEnglish("O-O-O") == "O-O-O")
        #expect(spanish.translateToEnglish("Pe4") == "e4")
        #expect(translateToEnglish("Cbd7", from: .spanish) == "Nbd7")
        #expect(SANNotationLanguage.english.translateToEnglish("Re2") == "Re2")
        #expect(spanish.translateFromEnglish("Rxe8+") == "Txe8+")
    }

    @Test("SAN description in Spanish")
    func spanishDescription() throws {
        #expect(try SANMove(san: "Nxe5+").description(language: .spanish) == "Cxe5+")
        #expect(try SANMove(san: "exd8=Q#").description(language: .spanish) == "exd8=D#")
        #expect(try SANMove(san: "Kf1").description(language: .spanish) == "Rf1")
        #expect(SANMove.kingsideCastling(isCheck: true, isCheckMate: false).description(language: .spanish) == "O-O+")
    }

    @Test("Spanish SAN resolves and replays a game")
    func spanishReplay() throws {
        let game = try Game(sanMoves: ["e4", "e5", "Cf3", "Cc6", "Ab5", "a6", "Axc6", "dxc6", "0-0", "Ag4"], language: .spanish)
        #expect(game.moveCount == 10)
        #expect(try game.sanMovesOfHistory().map(\.description) == ["e4", "e5", "Nf3", "Nc6", "Bb5", "a6", "Bxc6", "dxc6", "O-O", "Bg4"])
        #expect(try Game().resolve(san: "Cf3", language: .spanish) == ResolvedMove(move: .g1 >>> .f3))
        #expect(try SANMove(san: "Dxf7#", language: .spanish).description == "Qxf7#")
    }

    // MARK: - Legal moves and notation

    @Test("Legal moves expand promotions and expose UCI")
    func legalMovesExpandPromotions() throws {
        let game = try Game(with: "8/4P3/8/8/8/k7/8/K7 w - - 0 1")
        let promotions = game.legalMoves().filter { $0.move.start == .e7 }
        #expect(promotions.map(\.uci).sorted() == ["e7e8b", "e7e8n", "e7e8q", "e7e8r"])
        #expect(game.legalSANMoves().map(\.description).contains("e8=N"))
        #expect(ResolvedMove(uci: "e7e8n") == ResolvedMove(move: .e7 >>> .e8, promotion: .knight))
        #expect(ResolvedMove(uci: "0000") == nil)
    }

    @Test("Long algebraic notation")
    func longNotation() throws {
        var game = Game()
        #expect(try game.longNotation(for: ResolvedMove(move: .g1 >>> .f3)) == "Ng1-f3")
        #expect(try game.longNotation(for: ResolvedMove(move: .e2 >>> .e4)) == "e2-e4")
        try game.execute(san: "e4")
        try game.execute(san: "d5")
        #expect(try game.longNotation(for: ResolvedMove(move: .e4 >>> .d5)) == "e4xd5")
        #expect(try game.longNotation(for: ResolvedMove(move: .f1 >>> .b5), language: .spanish) == "Af1-b5+")
        #expect(NotationMove.long(from: .e7, to: .e8, piece: .pawn, promotion: .queen) == "e7-e8=Q")
    }

    // MARK: - Editing a game

    @Test("Replacing a middle move replays the tail")
    func replaceReplaysTail() throws {
        var game = try Game(sanMoves: ["e4", "e5", "Nf3", "Nc6", "Bb5", "a6"])
        let failures = try game.replace(ply: 4, with: try SANMove(san: "Bc4"))
        #expect(failures.isEmpty)
        #expect(try game.sanMovesOfHistory().map(\.description) == ["e4", "e5", "Nf3", "Nc6", "Bc4", "a6"])
    }

    @Test("Replacing a move reports the first tail move that no longer fits")
    func replaceReportsTailFailure() throws {
        var game = try Game(sanMoves: ["e4", "e5", "Nf3", "Nc6", "Bb5", "a6", "Bxc6"])
        let failures = try game.replace(ply: 4, with: try SANMove(san: "Bc4"))
        #expect(failures == [6: .notFound] || failures == [6: .illegal])
        #expect(game.moveCount == 6)
        #expect(throws: SANResolutionError.self) {
            try game.replace(ply: 0, with: try SANMove(san: "e5"))
        }
        #expect(game.moveCount == 6)
    }

    @Test("Creating a game from SAN reports the failing ply")
    func gameFromSANReportsFailure() throws {
        #expect(throws: SANReplayError(ply: 2, san: "Nf6", reason: .notFound)) {
            _ = try Game(sanMoves: ["e4", "e5", "Nf6"])
        }
        let fromFEN = try Game(initialFEN: "8/4P3/8/8/8/k7/8/K7 w - - 0 1", sanMoves: ["e8=N"])
        #expect(fromFEN.board[.e8] == Piece(knight: .white))
    }
}

extension Result where Success == ResolvedMove, Failure == SANResolutionError {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isAmbiguous: Bool {
        if case .failure(.ambiguous) = self { return true }
        return false
    }
}
