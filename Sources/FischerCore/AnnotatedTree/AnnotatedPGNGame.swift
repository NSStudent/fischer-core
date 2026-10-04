//
//  AnnotatedPGNGame.swift
//  FischerCore
//

/// A move that could not be played while reading a PGN.
public struct PGNReadIssue: Equatable, Sendable, CustomStringConvertible {
    /// The position where the move was found. The move and the rest of its
    /// line were dropped.
    public let path: MovePath
    /// The SAN as read.
    public let san: String
    /// Why it could not be played.
    public let reason: SANResolutionError

    public init(path: MovePath, san: String, reason: SANResolutionError) {
        self.path = path
        self.san = san
        self.reason = reason
    }

    public var description: String {
        "\(san) at \(path): \(reason)"
    }
}

/// Errors raised while reading an ``AnnotatedPGNGame``.
public enum AnnotatedPGNError: Error, Equatable, Sendable {
    /// The `FEN` tag is not a valid position.
    case invalidFEN(String)
    /// A move cannot be played (strict reading only).
    case illegalMove(PGNReadIssue)
    /// The text does not contain a game.
    case noGame
}

/// A PGN game with its tags, result and annotated move tree.
public struct AnnotatedPGNGame: Equatable, Sendable {
    /// The tag pairs.
    public var tags: [PGNTag: String]

    /// The order in which the tags were read. Used by ``PGNWriter`` after the
    /// seven tag roster.
    public var tagOrder: [PGNTag]

    /// The moves, variations and annotations.
    public var tree: AnnotatedMoveTree

    /// The game termination marker.
    public var result: PGNOutcome

    /// Moves dropped while reading in lenient mode.
    public var issues: [PGNReadIssue]

    public init(
        tags: [PGNTag: String] = [:],
        tagOrder: [PGNTag] = [],
        tree: AnnotatedMoveTree = AnnotatedMoveTree(),
        result: PGNOutcome = .undefined,
        issues: [PGNReadIssue] = []
    ) {
        self.tags = tags
        self.tagOrder = tagOrder
        self.tree = tree
        self.result = result
        self.issues = issues
    }

    /// Creates a game whose main line is the move history of `game`.
    ///
    /// The `White` and `Black` tags default to the game players and the
    /// result defaults to the game outcome (checkmate or stalemate) or `*`.
    public init(game: Game, tags: [PGNTag: String] = [:], result: PGNOutcome? = nil) {
        var allTags = tags
        if allTags[.white] == nil, !game.whitePlayer.isEmpty { allTags[.white] = game.whitePlayer }
        if allTags[.black] == nil, !game.blackPlayer.isEmpty { allTags[.black] = game.blackPlayer }
        let outcome = result ?? Self.outcome(of: game)
        self.init(tags: allTags, tree: AnnotatedMoveTree(game: game), result: outcome)
    }

    /// Reads the first game of `pgn`.
    ///
    /// - Throws: ``AnnotatedPGNError`` or a reader error for malformed tags.
    public init(pgn: String, strict: Bool = false) throws {
        var reader = MoveTreePGNReader(pgn)
        guard let game = try reader.readAnnotatedGame(strict: strict) else {
            throw AnnotatedPGNError.noGame
        }
        self = game
    }

    /// Converts a game read by ``PGNReader`` (moves and variations only).
    public init(_ moveTreePGN: MoveTreePGN) throws {
        var tags = moveTreePGN.tags
        let tree = try AnnotatedMoveTree(initialFEN: Self.validFEN(in: &tags))
        self.init(tags: tags, tree: tree, result: moveTreePGN.result ?? .undefined)
        if let comments = moveTreePGN.initialComment {
            for case let .text(text) in comments {
                self.tree.initialAnnotations.absorbComment(text, before: false)
            }
        }
        var issues: [PGNReadIssue] = []
        self.tree.children = (try? Self.resolve(
            moveTreePGN.tree.map(MoveTreeSource.init),
            game: tree.initialGame,
            parentPath: .root,
            issues: &issues,
            strict: false
        )) ?? []
        self.issues = issues
    }

    /// Writes the game as PGN text with ``PGNWriter``.
    public func pgn(options: PGNWriter.Options = .default) -> String {
        PGNWriter(options: options).write(self)
    }

    static func outcome(of game: Game) -> PGNOutcome {
        if game.isCheckmate {
            return game.playerTurn == .white ? .loss : .win
        }
        if game.isStalemate {
            return .draw
        }
        return .undefined
    }

    /// Returns the trimmed `FEN` tag when present.
    ///
    /// - Throws: ``AnnotatedPGNError/invalidFEN(_:)`` for an invalid FEN.
    static func validFEN(in tags: inout [PGNTag: String]) throws -> String? {
        guard let fen = tags[.fen]?.trimmingWhitespace(), !fen.isEmpty else { return nil }
        guard Position(fen: fen) != nil else {
            throw AnnotatedPGNError.invalidFEN(fen)
        }
        return fen
    }
}

// MARK: - Building from the reader

/// A minimal view over the raw trees produced by the readers.
protocol AnnotatedMoveSource {
    var sourceMove: SANMove { get }
    var sourceAnnotations: MoveAnnotations { get }
    var sourceNext: Self? { get }
    var sourceVariants: [Self] { get }
}

extension RawPGNNode: AnnotatedMoveSource {
    var sourceMove: SANMove { move }
    var sourceAnnotations: MoveAnnotations { annotations }
    var sourceNext: RawPGNNode? { next }
    var sourceVariants: [RawPGNNode] { variants }
}

struct MoveTreeSource: AnnotatedMoveSource {
    let tree: MoveTree
    init(_ tree: MoveTree) { self.tree = tree }
    var sourceMove: SANMove { tree.node }
    var sourceAnnotations: MoveAnnotations { MoveAnnotations() }
    var sourceNext: MoveTreeSource? { tree.next.map(MoveTreeSource.init) }
    var sourceVariants: [MoveTreeSource] { tree.variants.map(MoveTreeSource.init) }
}

extension AnnotatedPGNGame {
    init(raw: RawPGNGame, strict: Bool) throws {
        var tags = raw.tags
        let fen = try Self.validFEN(in: &tags)
        var tree = try AnnotatedMoveTree(initialFEN: fen)
        for comment in raw.line.leadingComments {
            tree.initialAnnotations.absorbComment(comment, before: false)
        }
        var issues: [PGNReadIssue] = []
        tree.children = try Self.resolve(
            raw.line.head,
            game: tree.initialGame,
            parentPath: .root,
            issues: &issues,
            strict: strict
        )
        let result = raw.line.result
            ?? raw.tags[.result].flatMap { PGNOutcome(rawValue: $0.trimmingWhitespace()) }
            ?? .undefined
        self.init(tags: tags, tagOrder: raw.tagOrder, tree: tree, result: result, issues: issues)
    }

    /// Resolves a raw line (a head plus its sibling variants) against `game`.
    ///
    /// The main continuation is walked iteratively so long games do not grow
    /// the stack; only variations recurse.
    static func resolve<Source: AnnotatedMoveSource>(
        _ head: Source?,
        game: Game,
        parentPath: MovePath,
        issues: inout [PGNReadIssue],
        strict: Bool
    ) throws -> [AnnotatedMoveNode] {
        var levels: [(siblings: [AnnotatedMoveNode], mainResolved: Bool)] = []
        var source = head
        var currentGame = game
        var path = parentPath

        while let current = source {
            var siblings: [AnnotatedMoveNode] = []
            var mainGame: Game?
            if let (node, after) = try resolveMove(current, in: currentGame, at: path, issues: &issues, strict: strict) {
                siblings.append(node)
                mainGame = after
            }
            for variant in current.sourceVariants {
                guard var (node, after) = try resolveMove(variant, in: currentGame, at: path, issues: &issues, strict: strict) else {
                    continue
                }
                node.children = try resolve(
                    variant.sourceNext,
                    game: after,
                    parentPath: path.appending(siblings.count),
                    issues: &issues,
                    strict: strict
                )
                siblings.append(node)
            }
            levels.append((siblings, mainGame != nil))
            guard let next = mainGame else { break }
            currentGame = next
            path = path.appending(0)
            source = current.sourceNext
        }

        var children: [AnnotatedMoveNode] = []
        for level in levels.reversed() {
            var siblings = level.siblings
            if level.mainResolved {
                siblings[0].children = children
            }
            children = siblings
        }
        return children
    }

    /// Resolves one move against `game`, returning the node (without
    /// children) and the game after it, or `nil` when it cannot be played.
    private static func resolveMove<Source: AnnotatedMoveSource>(
        _ source: Source,
        in game: Game,
        at path: MovePath,
        issues: inout [PGNReadIssue],
        strict: Bool
    ) throws -> (AnnotatedMoveNode, Game)? {
        switch game.resolveResult(source.sourceMove) {
        case let .failure(reason):
            let issue = PGNReadIssue(path: path, san: source.sourceMove.description, reason: reason)
            if strict { throw AnnotatedPGNError.illegalMove(issue) }
            issues.append(issue)
            return nil
        case let .success(resolved):
            guard let piece = game.board[resolved.move.start] else { return nil }
            var next = game
            try next.execute(uncheckedMove: resolved.move, promotion: { resolved.promotion ?? .queen })
            let san = game.san(forLegal: resolved, piece: piece, resultingGame: next)
            let node = AnnotatedMoveNode(
                moveNumber: game.fullmoves,
                color: game.playerTurn,
                san: san,
                move: resolved,
                annotations: source.sourceAnnotations
            )
            return (node, next)
        }
    }
}

public extension PGNReader {
    /// Reads every game of `pgn` as ``AnnotatedPGNGame`` values, keeping NAGs,
    /// comments, comment commands and variations.
    func parseAnnotated(_ pgn: String, strict: Bool = false) throws -> [AnnotatedPGNGame] {
        var reader = MoveTreePGNReader(pgn)
        return try reader.readAnnotatedGames(strict: strict)
    }
}
