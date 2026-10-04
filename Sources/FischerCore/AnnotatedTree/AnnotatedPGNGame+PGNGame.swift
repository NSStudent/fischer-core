//
//  AnnotatedPGNGame+PGNGame.swift
//  FischerCore
//

public extension AnnotatedPGNGame {
    /// Converts a game parsed with ``PGNGameParser`` into the annotated
    /// model, keeping comments, NAGs, comment commands and variations.
    ///
    /// Prefer ``AnnotatedPGNGame/init(pgn:strict:)``, which reads the text
    /// directly and faster; this initializer helps code that already holds
    /// ``PGNGame`` values.
    init(_ pgnGame: PGNGame) throws {
        var tags = pgnGame.tags
        var tree = try AnnotatedMoveTree(initialFEN: Self.validFEN(in: &tags))
        tree.initialAnnotations.absorb(pgnGame.initialComment, before: false)
        var issues: [PGNReadIssue] = []
        tree.children = try Self.resolve(
            RawPGNNode.line(from: pgnGame.elements[...]),
            game: tree.initialGame,
            parentPath: .root,
            issues: &issues,
            strict: false
        )
        self.init(tags: tags, tree: tree, result: pgnGame.result ?? .undefined, issues: issues)
    }
}

extension MoveAnnotations {
    /// Adds the values of 0.3 comment models.
    mutating func absorb(_ values: [PGNComment]?, before: Bool) {
        for comment in values ?? [] {
            switch comment {
            case let .text(text):
                let normalized = MoveAnnotations.normalizedText(text)
                guard !normalized.isEmpty else { continue }
                if before { commentsBefore.append(normalized) } else { comments.append(normalized) }
            case let .arrowList(arrows):
                self.arrows += arrows
            case let .squareList(squares):
                self.squares += squares
            case let .clockTime(value):
                clock = MoveAnnotations.normalizedText(value)
            case let .elapsedMoveTime(value):
                elapsedMoveTime = MoveAnnotations.normalizedText(value)
            case let .evaluation(value):
                evaluation = MoveAnnotations.normalizedText(value)
            }
        }
    }
}

extension RawPGNNode {
    /// Builds a linked line from PGN elements (white/black pairs with their
    /// comments and variations).
    static func line(from elements: ArraySlice<PGNElement>) -> RawPGNNode? {
        var head: RawPGNNode?
        var tail: RawPGNNode?
        var pendingAlternatives: [RawPGNNode] = []

        func append(
            turn: UInt,
            color: PlayerColor,
            move: SANMove,
            before: [PGNComment]?,
            nags: [NAG]?,
            after: [PGNComment]?,
            variations: [[PGNElement]]?
        ) {
            let node = RawPGNNode(turn: turn, color: color, move: move)
            node.annotations.absorb(before, before: true)
            node.annotations.absorb(after, before: false)
            for nag in nags ?? [] { node.annotations.add(nag) }
            node.variants = pendingAlternatives
            pendingAlternatives = []
            for variation in variations ?? [] {
                guard let branch = line(from: variation[...]) else { continue }
                if branch.color == color {
                    node.variants.append(branch)
                } else {
                    // A variation that starts with the other side's move is an
                    // alternative to the next move.
                    pendingAlternatives.append(branch)
                }
            }
            if let tail { tail.next = node } else { head = node }
            tail = node
        }

        for element in elements {
            if let white = element.whiteMove {
                append(
                    turn: element.turn, color: .white, move: white,
                    before: element.previousWhiteCommentList, nags: element.whiteEvaluation,
                    after: element.postWhiteCommentList, variations: element.postWhiteVariation
                )
            }
            if let black = element.blackMove {
                append(
                    turn: element.turn, color: .black, move: black,
                    before: element.previousBlackCommentList, nags: element.blackEvaluation,
                    after: element.postBlackCommentList, variations: element.postBlackVariation
                )
            }
        }
        return head
    }
}

/// Remaining clock times of both players at a position.
public struct PGNClockSnapshot: Equatable, Sendable {
    /// White's remaining time in seconds, from its last `[%clk]`.
    public var white: Double?
    /// Black's remaining time in seconds, from its last `[%clk]`.
    public var black: Double?

    public init(white: Double? = nil, black: Double? = nil) {
        self.white = white
        self.black = black
    }
}

public extension AnnotatedMoveTree {
    /// The last known `[%clk]` time of each player along the line to `path`.
    func clocks(at path: MovePath) -> PGNClockSnapshot {
        var snapshot = PGNClockSnapshot()
        for reference in line(through: path) {
            guard let seconds = reference.node.annotations.clockSeconds else { continue }
            switch reference.node.color {
            case .white: snapshot.white = seconds
            case .black: snapshot.black = seconds
            }
        }
        return snapshot
    }
}
