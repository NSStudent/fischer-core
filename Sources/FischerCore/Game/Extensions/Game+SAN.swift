//
//  Game+SAN.swift
//  FischerCore
//

public extension ResolvedMove {
    /// The move in UCI notation, for example `"e2e4"` or `"e7e8n"`.
    var uci: String {
        "\(move.start)\(move.end)\(promotion?.uciValue ?? "")"
    }

    /// Parses a UCI move such as `"g1f3"` or `"e7e8q"`.
    ///
    /// Returns `nil` for malformed text and for the null move (`"0000"`).
    init?(uci: String) {
        guard let parsed = try? UCIMoveParser().parse(uci.lowercased()),
              case let .move(value) = parsed else {
            return nil
        }
        self.init(move: value.asMove(), promotion: value.promotion)
    }
}

// MARK: - Legal moves and SAN generation

public extension Game {
    /// Every legal move in the current position.
    ///
    /// Unlike ``availableMoves()``, promotions are expanded into one move per
    /// promotion piece (queen, rook, bishop and knight).
    ///
    /// - Parameter considerHalfmoves: When `true` (the default), no moves are
    ///   returned once the fifty-move counter reaches 100 halfmoves.
    func legalMoves(considerHalfmoves: Bool = true) -> [ResolvedMove] {
        var result: [ResolvedMove] = []
        for square in board.bitboard(for: playerTurn) {
            let targets = movesBitboardForPiece(at: square, considerHalfmoves: considerHalfmoves)
            guard !targets.isEmpty else { continue }
            let isPawn = board[square]?.kind.isPawn ?? false
            for target in targets {
                let move = square >>> target
                if isPawn && target.rank == Rank(endFor: playerTurn) {
                    for promotion in [PromotionPiece.queen, .rook, .bishop, .knight] {
                        result.append(ResolvedMove(move: move, promotion: promotion))
                    }
                } else {
                    result.append(ResolvedMove(move: move))
                }
            }
        }
        return result
    }

    /// Every legal move in the current position written as SAN.
    func legalSANMoves(considerHalfmoves: Bool = true) -> [SANMove] {
        legalMoves(considerHalfmoves: considerHalfmoves).compactMap { try? san(for: $0) }
    }

    /// Returns the SAN for a legal move in the current position.
    ///
    /// The SAN includes the minimal disambiguation, the capture marker, the
    /// promotion piece and the check (`+`) or mate (`#`) marker computed after
    /// applying the actual promotion piece.
    ///
    /// A pawn move to the last rank without a promotion piece is treated as a
    /// queen promotion.
    ///
    /// - Throws: ``SANResolutionError/illegal`` when the move is not legal.
    func san(for resolvedMove: ResolvedMove) throws -> SANMove {
        let move = resolvedMove.move
        guard let piece = board[move.start],
              piece.color == playerTurn,
              isLegal(move: move, considerHalfmoves: false) else {
            throw SANResolutionError.illegal
        }

        let promotes = piece.kind.isPawn && move.end.rank == Rank(endFor: piece.color)
        let promotion: PromotionPiece? = promotes ? (resolvedMove.promotion ?? .queen) : nil

        var after = self
        try after.execute(uncheckedMove: move, promotion: { promotion ?? .queen })
        return san(forLegal: ResolvedMove(move: move, promotion: promotion), piece: piece, resultingGame: after)
    }

    /// Returns the long algebraic notation for a legal move, for example
    /// `"Ng1-f3"`, `"e7xd8=Q+"` or `"O-O"`.
    func longNotation(for resolvedMove: ResolvedMove, language: SANNotationLanguage = .english) throws -> String {
        let san = try san(for: resolvedMove)
        if san.isCastling {
            return san.description
        }
        guard let piece = board[resolvedMove.move.start] else {
            throw SANResolutionError.illegal
        }
        return NotationMove.long(
            from: resolvedMove.move.start,
            to: resolvedMove.move.end,
            piece: piece.kind,
            promotion: san.promotion,
            isCapture: san.isCapture,
            isCheck: san.isCheck,
            isCheckmate: san.isCheckmate,
            language: language
        )
    }
}

extension Game {
    /// Builds the SAN of a move already known to be legal, given the game
    /// after playing it. Avoids replaying the move when the caller already
    /// did.
    func san(forLegal resolvedMove: ResolvedMove, piece: Piece, resultingGame after: Game) -> SANMove {
        let move = resolvedMove.move
        let isCheck = after.kingIsChecked
        let isCheckmate = isCheck && !after.hasAnyLegalMove()

        if piece.kind.isKing && move.isCastle(for: piece.color) {
            return move.end.file == .g
                ? .kingsideCastling(isCheck: isCheck && !isCheckmate, isCheckMate: isCheckmate)
                : .queensideCastling(isCheck: isCheck && !isCheckmate, isCheckMate: isCheckmate)
        }

        let isCapture = board[move.end] != nil
            || (piece.kind.isPawn && move.end == enPassantTarget && move.start.file != move.end.file)

        let disambiguation: SANMove.FromPosition?
        if piece.kind.isPawn {
            disambiguation = isCapture ? .file(move.start.file) : nil
        } else {
            let rivals = board.bitboard(for: piece).filter {
                $0 != move.start && isLegal(move: $0 >>> move.end, considerHalfmoves: false)
            }
            if rivals.isEmpty {
                disambiguation = nil
            } else if !rivals.contains(where: { $0.file == move.start.file }) {
                disambiguation = .file(move.start.file)
            } else if !rivals.contains(where: { $0.rank == move.start.rank }) {
                disambiguation = .rank(move.start.rank)
            } else {
                disambiguation = .square(move.start)
            }
        }

        let promotes = piece.kind.isPawn && move.end.rank == Rank(endFor: piece.color)
        return .san(SANMove.SANDefaultMove(
            piece: piece.kind,
            from: disambiguation,
            isCapture: isCapture,
            toSquare: move.end,
            promotionTo: promotes ? (resolvedMove.promotion ?? .queen) : nil,
            isCheck: isCheck && !isCheckmate,
            isCheckmate: isCheckmate
        ))
    }
}

// MARK: - SAN resolution

public extension Game {
    /// Every legal move that matches the piece, destination, disambiguation
    /// and promotion written in `san`.
    ///
    /// Capture and check markers are ignored. When the SAN does not include a
    /// promotion piece, every promotion choice of a matching pawn move is
    /// returned. The halfmove clock is ignored.
    func candidates(for san: SANMove) -> [ResolvedMove] {
        switch san {
        case .kingsideCastling, .queensideCastling:
            let rank = Rank(startFor: playerTurn)
            let start = Square(file: .e, rank: rank)
            let end = Square(file: isQueenside(san) ? .c : .g, rank: rank)
            guard board[start] == Piece(king: playerTurn),
                  isLegal(move: start >>> end, considerHalfmoves: false) else {
                return []
            }
            return [ResolvedMove(move: start >>> end)]
        case let .san(defaultMove):
            let piece = Piece(kind: defaultMove.piece, color: playerTurn)
            var result: [ResolvedMove] = []
            for start in board.bitboard(for: piece) where matches(start, defaultMove.from) {
                guard movesBitboardForPiece(at: start, considerHalfmoves: false)[defaultMove.toSquare] else {
                    continue
                }
                let move = start >>> defaultMove.toSquare
                if piece.kind.isPawn && defaultMove.toSquare.rank == Rank(endFor: playerTurn) {
                    if let promotion = defaultMove.promotionTo {
                        result.append(ResolvedMove(move: move, promotion: promotion))
                    } else {
                        for promotion in [PromotionPiece.queen, .rook, .bishop, .knight] {
                            result.append(ResolvedMove(move: move, promotion: promotion))
                        }
                    }
                } else {
                    result.append(ResolvedMove(move: move))
                }
            }
            return result
        }
    }

    /// Resolves `san` against the current position without executing it.
    ///
    /// In lenient mode (the default) the capture and check markers are
    /// ignored, a missing promotion piece promotes to a queen and an
    /// unnecessary promotion piece is ignored. In strict mode each of those
    /// mismatches is reported. Ambiguous moves are reported in both modes.
    func resolveResult(_ san: SANMove, strict: Bool = false) -> Result<ResolvedMove, SANResolutionError> {
        let candidates = candidates(for: san)

        guard !candidates.isEmpty else {
            return .failure(hasMatchingPiece(for: san) ? .illegal : .notFound)
        }

        var distinctMoves: [Move] = []
        for candidate in candidates where !distinctMoves.contains(candidate.move) {
            distinctMoves.append(candidate.move)
        }
        guard distinctMoves.count == 1 else {
            return .failure(.ambiguous(distinctMoves.map { ResolvedMove(move: $0) }))
        }

        let move = distinctMoves[0]
        let promotes = requiresPromotion(move: move)
        let resolved: ResolvedMove
        if promotes {
            if let promotion = san.promotion {
                resolved = ResolvedMove(move: move, promotion: promotion)
            } else if strict {
                return .failure(.missingPromotion)
            } else {
                resolved = ResolvedMove(move: move, promotion: .queen)
            }
        } else if san.promotion != nil && strict {
            return .failure(.unexpectedPromotion)
        } else {
            resolved = ResolvedMove(move: move)
        }

        if strict {
            guard let canonical = try? self.san(for: resolved) else {
                return .failure(.illegal)
            }
            if canonical.isCapture != san.isCapture {
                return .failure(.captureMismatch)
            }
            if canonical.isCheck != san.isCheck || canonical.isCheckmate != san.isCheckmate {
                return .failure(.checkMismatch)
            }
        }
        return .success(resolved)
    }

    /// Resolves SAN text against the current position.
    ///
    /// The text is parsed with ``SANParsingOptions/lenient`` unless `strict`
    /// is `true`, in which case only exact SAN is accepted.
    func resolveResult(
        san text: String,
        language: SANNotationLanguage = .english,
        strict: Bool = false
    ) -> Result<ResolvedMove, SANResolutionError> {
        guard let san = try? SANMove(san: text, language: language, options: strict ? .strict : .lenient) else {
            return .failure(.invalidNotation(text))
        }
        return resolveResult(san, strict: strict)
    }

    #if compiler(>=6.0)
    /// Resolves `san` against the current position without executing it.
    ///
    /// See ``resolveResult(_:strict:)`` for the lenient and strict rules.
    ///
    /// - Throws: ``SANResolutionError``.
    func resolve(_ san: SANMove, strict: Bool = false) throws(SANResolutionError) -> ResolvedMove {
        try resolveResult(san, strict: strict).get()
    }

    /// Resolves SAN text against the current position without executing it.
    ///
    /// - Throws: ``SANResolutionError``.
    func resolve(
        san text: String,
        language: SANNotationLanguage = .english,
        strict: Bool = false
    ) throws(SANResolutionError) -> ResolvedMove {
        try resolveResult(san: text, language: language, strict: strict).get()
    }
    #else
    func resolve(_ san: SANMove, strict: Bool = false) throws -> ResolvedMove {
        try resolveResult(san, strict: strict).get()
    }

    func resolve(
        san text: String,
        language: SANNotationLanguage = .english,
        strict: Bool = false
    ) throws -> ResolvedMove {
        try resolveResult(san: text, language: language, strict: strict).get()
    }
    #endif
}

private extension Game {
    func matches(_ square: Square, _ from: SANMove.FromPosition?) -> Bool {
        switch from {
        case .none: return true
        case let .file(file): return square.file == file
        case let .rank(rank): return square.rank == rank
        case let .square(expected): return square == expected
        }
    }

    func isQueenside(_ san: SANMove) -> Bool {
        if case .queensideCastling = san { return true }
        return false
    }

    /// Whether a piece matching `san` could reach the destination if king
    /// safety were ignored. Distinguishes `.illegal` from `.notFound`.
    func hasMatchingPiece(for san: SANMove) -> Bool {
        switch san {
        case .kingsideCastling, .queensideCastling:
            return true
        case let .san(defaultMove):
            let piece = Piece(kind: defaultMove.piece, color: playerTurn)
            let own = board.bitboard(for: playerTurn)
            let enemy = board.bitboard(for: playerTurn.inverse())
            let occupied = own | enemy
            let target = defaultMove.toSquare
            return board.bitboard(for: piece).contains { start in
                guard matches(start, defaultMove.from) else { return false }
                let attacks = start.attacks(for: piece, stoppers: occupied)
                if piece.kind.isPawn {
                    let origin = Bitboard(square: start)
                    let empty = ~occupied
                    let single = origin.pawnPushes(for: playerTurn, empty: empty)
                    let double = (origin & Bitboard(startFor: piece))
                        .pawnPushes(for: playerTurn, empty: empty)
                        .pawnPushes(for: playerTurn, empty: empty)
                    let enPassant = enPassantTarget.map { Bitboard(square: $0) } ?? 0
                    return (single | double | (attacks & (enemy | enPassant)))[target]
                }
                return (attacks & ~own)[target]
            }
        }
    }
}

// MARK: - Building and editing games from SAN

public extension Game {
    /// Creates a game from a starting FEN and a list of SAN moves.
    ///
    /// Moves are parsed leniently (see ``SANParsingOptions/lenient``).
    ///
    /// - Parameters:
    ///   - initialFEN: The starting position. Defaults to the standard one.
    ///   - sanMoves: The moves in order.
    ///   - language: The language of the piece letters.
    ///   - strict: Whether to resolve each move strictly.
    /// - Throws: ``PositionError`` for an invalid FEN, or ``SANReplayError``
    ///   with the first move that cannot be played.
    init(
        initialFEN: String = Game().initialFen,
        sanMoves: [String],
        language: SANNotationLanguage = .english,
        strict: Bool = false
    ) throws {
        var game = try Game(with: initialFEN)
        for (ply, text) in sanMoves.enumerated() {
            switch game.resolveResult(san: text, language: language, strict: strict) {
            case let .success(resolved):
                try game.execute(resolvedMove: resolved, considerHalfmoves: false)
            case let .failure(reason):
                throw SANReplayError(ply: ply, san: text, reason: reason)
            }
        }
        self = game
    }

    /// Replaces the move at `ply` and optionally replays the moves that
    /// followed it.
    ///
    /// The game is rewound to `ply`, `san` is played, and when
    /// `replayingTail` is `true` the original following moves are replayed
    /// leniently from their SAN. Replay stops at the first move that no longer
    /// fits; it and the rest of the tail are dropped.
    ///
    /// - Parameters:
    ///   - ply: The zero-based index in ``moveHistory`` to replace.
    ///   - san: The new move.
    ///   - replayingTail: Whether to replay the moves after `ply`.
    /// - Returns: The errors of the tail moves that could not be replayed,
    ///   keyed by their ply. Empty when the whole tail was replayed.
    /// - Throws: ``SANResolutionError`` when `ply` is out of range or `san`
    ///   cannot be played; the game is left unchanged in that case.
    @discardableResult
    mutating func replace(
        ply: Int,
        with san: SANMove,
        replayingTail: Bool = true
    ) throws -> [Int: SANResolutionError] {
        guard moveHistory.indices.contains(ply) else {
            throw SANResolutionError.notFound
        }
        var working = self
        let tailSANs = try working.sanMovesOfHistory().dropFirst(ply + 1)
        while working.moveHistory.count > ply {
            working.undoMove()
        }
        let replacement = try working.resolveResult(san).get()
        try working.execute(resolvedMove: replacement, considerHalfmoves: false)

        var failures: [Int: SANResolutionError] = [:]
        if replayingTail {
            for (offset, tailSAN) in tailSANs.enumerated() {
                switch working.resolveResult(tailSAN.withCheckFlags(isCheck: false, isCheckmate: false)) {
                case let .success(resolved):
                    try working.execute(resolvedMove: resolved, considerHalfmoves: false)
                case let .failure(reason):
                    failures[ply + 1 + offset] = reason
                }
                if !failures.isEmpty { break }
            }
        }
        working.undoHistory = []
        self = working
        return failures
    }

    /// The SAN of every move in ``moveHistory``, computed in context.
    func sanMovesOfHistory() throws -> [SANMove] {
        var replay = try Game(with: initialFen)
        return try moveHistory.map { element in
            let resolved = ResolvedMove(move: element.move, promotion: element.promotionPiece)
            let san = try replay.san(for: resolved)
            try replay.execute(uncheckedMove: element.move, promotion: { element.promotionPiece ?? .queen })
            return san
        }
    }
}
