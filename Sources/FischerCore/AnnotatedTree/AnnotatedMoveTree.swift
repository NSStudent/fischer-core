//
//  AnnotatedMoveTree.swift
//  FischerCore
//

/// A mutable tree of moves with annotations, starting from a position.
///
/// The tree is a value type. Nodes are addressed with ``MovePath``:
/// `children[0]` at every level is the main line and higher indices are
/// variations. Every node stores its move already resolved, so positions can
/// be replayed without parsing SAN again.
///
/// ```swift
/// var tree = AnnotatedMoveTree()
/// let e4 = try tree.insert(san: "e4", at: .root)        // [0]
/// let e5 = try tree.insert(san: "e5", at: e4)           // [0, 0]
/// let c5 = try tree.insert(san: "c5", at: e4)           // [0, 1] variation
/// tree.updateAnnotations(at: c5) { $0.toggle(.goodMove) }
/// let fen = tree.fen(at: c5)
/// ```
public struct AnnotatedMoveTree: Equatable, Sendable {
    /// The FEN of the initial position.
    public let initialFEN: String

    /// Annotations of the initial position: the game comment and any
    /// comment commands written before the first move.
    public var initialAnnotations: MoveAnnotations

    /// Text comments before the first move (the game comment).
    public var initialComments: [String] {
        get { initialAnnotations.comments }
        set { initialAnnotations.comments = newValue }
    }

    /// The moves from the initial position. The first one is the main line.
    public var children: [AnnotatedMoveNode]

    private let startGame: Game

    /// Creates an empty tree starting from `initialFEN`, or from the standard
    /// position when `nil`.
    ///
    /// - Throws: ``PositionError`` when the FEN is invalid.
    public init(initialFEN: String? = nil, initialComments: [String] = [], children: [AnnotatedMoveNode] = []) throws {
        let game = try initialFEN.map { try Game(with: $0) } ?? Game()
        self.init(startGame: game, initialComments: initialComments, children: children)
    }

    /// Creates an empty tree from the standard starting position.
    public init() {
        self.init(startGame: Game(), initialComments: [], children: [])
    }

    /// Creates a tree whose main line is the move history of `game`.
    public init(game: Game) {
        let start = (try? Game(with: game.initialFen)) ?? Game()
        var replay = start
        var line: [AnnotatedMoveNode] = []
        for element in game.moveHistory {
            let resolved = ResolvedMove(move: element.move, promotion: element.promotionPiece)
            guard let san = try? replay.san(for: resolved) else { break }
            line.append(AnnotatedMoveNode(moveNumber: replay.fullmoves, color: replay.playerTurn, san: san, move: resolved))
            guard (try? replay.execute(resolvedMove: resolved, considerHalfmoves: false)) != nil else { break }
        }
        var tail: [AnnotatedMoveNode] = []
        for var node in line.reversed() {
            node.children = tail
            tail = [node]
        }
        self.init(startGame: start, initialComments: [], children: tail)
    }

    init(startGame: Game, initialComments: [String], children: [AnnotatedMoveNode]) {
        var start = startGame
        start.rewindToStart()
        start.undoHistory = []
        self.startGame = start
        self.initialFEN = start.position.fen()
        self.initialAnnotations = MoveAnnotations(comments: initialComments)
        self.children = children
    }

    public static func == (lhs: AnnotatedMoveTree, rhs: AnnotatedMoveTree) -> Bool {
        lhs.initialFEN == rhs.initialFEN
            && lhs.initialAnnotations == rhs.initialAnnotations
            && lhs.children == rhs.children
    }

    /// Whether the tree starts from the standard position.
    public var startsFromStandardPosition: Bool {
        initialFEN == Game().initialFen
    }

    /// Whether the tree has no moves.
    public var isEmpty: Bool { children.isEmpty }
}

// MARK: - Reading

public extension AnnotatedMoveTree {
    /// The node at `path`, or `nil` for the root or a missing path.
    subscript(path: MovePath) -> AnnotatedMoveNode? {
        node(at: path)
    }

    /// The node at `path`, or `nil` for the root or a missing path.
    func node(at path: MovePath) -> AnnotatedMoveNode? {
        guard !path.isRoot else { return nil }
        var level = children
        var current: AnnotatedMoveNode?
        for index in path.components {
            guard level.indices.contains(index) else { return nil }
            current = level[index]
            level = level[index].children
        }
        return current
    }

    /// The moves that follow the position at `path` (the root children for
    /// ``MovePath/root``). Empty for a missing path.
    func children(at path: MovePath) -> [AnnotatedMoveNode] {
        path.isRoot ? children : (node(at: path)?.children ?? [])
    }

    /// Whether `path` exists. The root always exists.
    func contains(_ path: MovePath) -> Bool {
        path.isRoot || node(at: path) != nil
    }

    /// The longest prefix of `path` that exists in the tree.
    func clamp(_ path: MovePath) -> MovePath {
        var level = children
        var clamped: [Int] = []
        for index in path.components {
            guard level.indices.contains(index) else { break }
            clamped.append(index)
            level = level[index].children
        }
        return MovePath(clamped)
    }

    /// The annotations of the node at `path`.
    func annotations(at path: MovePath) -> MoveAnnotations? {
        node(at: path)?.annotations
    }

    /// The end of the main continuation that starts at `path`.
    func mainlineEnd(from path: MovePath = .root) -> MovePath {
        var result = clamp(path)
        var level = children(at: result)
        while let first = level.first {
            result = result.mainContinuation
            level = first.children
        }
        return result
    }

    /// The path of the main continuation of `path`, or `nil` at a leaf.
    func nextMainlinePath(from path: MovePath) -> MovePath? {
        children(at: path).isEmpty ? nil : path.mainContinuation
    }

    /// The nodes from the first move to the node at `path`, inclusive.
    func line(through path: MovePath) -> [AnnotatedMoveReference] {
        var result: [AnnotatedMoveReference] = []
        var level = children
        var current = MovePath.root
        for index in path.components {
            guard level.indices.contains(index) else { break }
            current = current.appending(index)
            result.append(AnnotatedMoveReference(path: current, node: level[index]))
            level = level[index].children
        }
        return result
    }

    /// The nodes of the main continuation after `path`, excluding `path`.
    func continuation(after path: MovePath) -> [AnnotatedMoveReference] {
        var result: [AnnotatedMoveReference] = []
        var current = clamp(path)
        var level = children(at: current)
        while let first = level.first {
            current = current.mainContinuation
            result.append(AnnotatedMoveReference(path: current, node: first))
            level = first.children
        }
        return result
    }

    /// The main line from the first move.
    var mainline: [AnnotatedMoveReference] {
        continuation(after: .root)
    }

    /// The alternatives to the main continuation of `path`, that is the
    /// variations that start after the position at `path`.
    func variations(after path: MovePath) -> [AnnotatedMoveReference] {
        children(at: path).enumerated().dropFirst().map { index, node in
            AnnotatedMoveReference(path: path.appending(index), node: node)
        }
    }

    /// The siblings of the node at `path`, including itself, in order.
    func siblings(of path: MovePath) -> [AnnotatedMoveReference] {
        guard let parent = path.parent else { return [] }
        return children(at: parent).enumerated().map { index, node in
            AnnotatedMoveReference(path: parent.appending(index), node: node)
        }
    }

    /// Every node in depth-first order (main continuation before variations).
    var allReferences: [AnnotatedMoveReference] {
        var result: [AnnotatedMoveReference] = []
        var stack: [(MovePath, AnnotatedMoveNode)] = children.enumerated().reversed().map { (MovePath([$0.offset]), $0.element) }
        while let (path, node) = stack.popLast() {
            result.append(AnnotatedMoveReference(path: path, node: node))
            for (index, child) in node.children.enumerated().reversed() {
                stack.append((path.appending(index), child))
            }
        }
        return result
    }

    /// The number of nodes in the tree.
    var nodeCount: Int {
        var count = 0
        var stack: [AnnotatedMoveNode] = children
        while let node = stack.popLast() {
            count += 1
            stack += node.children
        }
        return count
    }

    /// Every line from the first move to a leaf, main line first. Useful to
    /// train a repertoire line by line.
    var allLines: [[AnnotatedMoveReference]] {
        var result: [[AnnotatedMoveReference]] = []
        var line: [AnnotatedMoveReference] = []
        for reference in allReferences {
            line.removeLast(line.count - (reference.path.depth - 1))
            line.append(reference)
            if reference.node.children.isEmpty {
                result.append(line)
            }
        }
        return result
    }

    /// The path reached by playing `moves` from the root, or `nil` when a
    /// move is not in the tree.
    func path(for moves: [ResolvedMove]) -> MovePath? {
        var path = MovePath.root
        var level = children
        for move in moves {
            guard let index = level.firstIndex(where: { $0.move.move == move.move && promotionMatches($0.move, move) }) else {
                return nil
            }
            path = path.appending(index)
            level = level[index].children
        }
        return path
    }

    /// The path reached by playing UCI `moves` from the root.
    func path(forUCI moves: [String]) -> MovePath? {
        let resolved = moves.compactMap(ResolvedMove.init(uci:))
        guard resolved.count == moves.count else { return nil }
        return path(for: resolved)
    }

    /// The SAN moves from the first move to `path`.
    func sanLine(through path: MovePath) -> [SANMove] {
        line(through: path).map(\.node.san)
    }

    /// The UCI moves from the first move to `path`.
    func uciLine(through path: MovePath) -> [String] {
        line(through: path).map(\.node.uci)
    }

    /// A game with the moves from the root to `path` played, or `nil` for a
    /// missing path.
    func game(at path: MovePath) -> Game? {
        var game = startGame
        var level = children
        for index in path.components {
            guard level.indices.contains(index) else { return nil }
            let node = level[index]
            do {
                try game.execute(resolvedMove: node.move, considerHalfmoves: false)
            } catch {
                return nil
            }
            level = node.children
        }
        return game
    }

    /// The FEN of the position at `path`.
    func fen(at path: MovePath) -> String? {
        game(at: path)?.position.fen()
    }

    /// A game at the initial position.
    var initialGame: Game { startGame }

    private func promotionMatches(_ lhs: ResolvedMove, _ rhs: ResolvedMove) -> Bool {
        lhs.promotion == rhs.promotion || (lhs.promotion == .queen && rhs.promotion == nil)
    }
}

// MARK: - Editing

public extension AnnotatedMoveTree {
    /// Replaces the annotations of the node at `path`.
    ///
    /// - Returns: `false` when the path does not exist.
    @discardableResult
    mutating func setAnnotations(_ annotations: MoveAnnotations, at path: MovePath) -> Bool {
        updateNode(at: path) { $0.annotations = annotations }
    }

    /// Edits the annotations of the node at `path` in place.
    ///
    /// - Returns: `false` when the path does not exist.
    @discardableResult
    mutating func updateAnnotations(at path: MovePath, _ body: (inout MoveAnnotations) -> Void) -> Bool {
        updateNode(at: path) { body(&$0.annotations) }
    }

    /// Edits the node at `path` in place. The move itself cannot change; use
    /// ``insert(_:at:)`` and ``delete(at:)`` for that.
    ///
    /// - Returns: `false` when the path does not exist.
    @discardableResult
    mutating func updateNode(at path: MovePath, _ body: (inout AnnotatedMoveNode) -> Void) -> Bool {
        guard !path.isRoot else { return false }
        return Self.mutate(&children, path.components[...]) { nodes, index in
            body(&nodes[index])
        }
    }

    /// Plays `move` after the position at `path`.
    ///
    /// When the move already exists there, the tree is unchanged and the
    /// existing path is returned. Otherwise the move becomes the main
    /// continuation if there is none, or a new last variation.
    ///
    /// - Returns: The path of the new or existing node.
    /// - Throws: ``AnnotatedMoveTreeError``.
    @discardableResult
    mutating func insert(_ move: ResolvedMove, at path: MovePath) throws -> MovePath {
        guard let game = game(at: path) else {
            throw AnnotatedMoveTreeError.invalidPath(path)
        }
        let resolved: ResolvedMove
        if game.requiresPromotion(move: move.move) {
            resolved = ResolvedMove(move: move.move, promotion: move.promotion ?? .queen)
        } else {
            resolved = ResolvedMove(move: move.move)
        }
        guard game.isLegal(move: resolved.move, considerHalfmoves: false) else {
            throw AnnotatedMoveTreeError.illegalMove(.illegal)
        }
        let siblings = children(at: path)
        if let existing = siblings.firstIndex(where: { $0.move == resolved }) {
            return path.appending(existing)
        }
        let san = try game.san(for: resolved)
        let node = AnnotatedMoveNode(
            moveNumber: game.fullmoves,
            color: game.playerTurn,
            san: san,
            move: resolved
        )
        if path.isRoot {
            children.append(node)
            return path.appending(children.count - 1)
        }
        var newIndex = 0
        Self.mutate(&children, path.components[...]) { nodes, index in
            nodes[index].children.append(node)
            newIndex = nodes[index].children.count - 1
        }
        return path.appending(newIndex)
    }

    /// Plays SAN text after the position at `path`. The text is parsed
    /// leniently.
    ///
    /// - Returns: The path of the new or existing node.
    /// - Throws: ``AnnotatedMoveTreeError``.
    @discardableResult
    mutating func insert(san: String, language: SANNotationLanguage = .english, at path: MovePath) throws -> MovePath {
        guard let game = game(at: path) else {
            throw AnnotatedMoveTreeError.invalidPath(path)
        }
        switch game.resolveResult(san: san, language: language) {
        case let .success(resolved):
            return try insert(resolved, at: path)
        case let .failure(error):
            throw AnnotatedMoveTreeError.illegalMove(error)
        }
    }

    /// Plays a sequence of moves after `path`, for example an engine
    /// principal variation. Existing moves are reused.
    ///
    /// - Returns: The path of the last move played, or `nil` when the first
    ///   move cannot be played. Stops at the first illegal move.
    @discardableResult
    mutating func insertLine(_ moves: [ResolvedMove], at path: MovePath) -> MovePath? {
        var current = path
        var last: MovePath?
        for move in moves {
            guard let next = try? insert(move, at: current) else { break }
            current = next
            last = next
        }
        return last
    }

    /// Plays a sequence of UCI moves after `path`.
    @discardableResult
    mutating func insertLine(uci moves: [String], at path: MovePath) -> MovePath? {
        var resolved: [ResolvedMove] = []
        for text in moves {
            guard let move = ResolvedMove(uci: text) else { break }
            resolved.append(move)
        }
        return insertLine(resolved, at: path)
    }

    /// Deletes the node at `path` and everything after it.
    ///
    /// - Returns: The parent path, or `nil` when the path does not exist.
    @discardableResult
    mutating func delete(at path: MovePath) -> MovePath? {
        guard let parent = path.parent, let index = path.lastIndex, contains(path) else { return nil }
        if parent.isRoot {
            children.remove(at: index)
        } else {
            Self.mutate(&children, parent.components[...]) { nodes, nodeIndex in
                nodes[nodeIndex].children.remove(at: index)
            }
        }
        return parent
    }

    /// Deletes every move after `path`, keeping the node itself.
    ///
    /// - Returns: `false` when the path does not exist.
    @discardableResult
    mutating func deleteContinuation(after path: MovePath) -> Bool {
        if path.isRoot {
            children.removeAll()
            return true
        }
        return updateNode(at: path) { $0.children.removeAll() }
    }

    /// Moves the node at `path` one position up among its siblings. Promoting
    /// the first variation makes it the main continuation.
    ///
    /// - Returns: The new path, or `nil` when the node is already first or
    ///   the path does not exist.
    @discardableResult
    mutating func promote(at path: MovePath) -> MovePath? {
        guard let parent = path.parent, let index = path.lastIndex, index > 0, contains(path) else {
            return nil
        }
        reorder(parent: parent) { $0.swapAt(index, index - 1) }
        return parent.appending(index - 1)
    }

    /// Moves the node at `path` one position down among its siblings.
    ///
    /// - Returns: The new path, or `nil` when the node is already last or the
    ///   path does not exist.
    @discardableResult
    mutating func demote(at path: MovePath) -> MovePath? {
        guard let parent = path.parent, let index = path.lastIndex, contains(path),
              index + 1 < children(at: parent).count else {
            return nil
        }
        reorder(parent: parent) { $0.swapAt(index, index + 1) }
        return parent.appending(index + 1)
    }

    /// Makes the line through `path` the main line: at every branching point
    /// along the path, its move becomes the first child.
    ///
    /// - Returns: The new path (all zeros), or `nil` when the path does not
    ///   exist.
    @discardableResult
    mutating func makeMainline(at path: MovePath) -> MovePath? {
        guard contains(path) else { return nil }
        var prefix = MovePath.root
        for index in path.components {
            if index > 0 {
                reorder(parent: prefix) { nodes in
                    let node = nodes.remove(at: index)
                    nodes.insert(node, at: 0)
                }
            }
            prefix = prefix.appending(0)
        }
        return prefix
    }

    /// Adds every line of `other` to this tree, merging the annotations of
    /// moves that already exist.
    ///
    /// - Throws: ``AnnotatedMoveTreeError/differentInitialPosition`` when the
    ///   trees start from different positions.
    mutating func merge(_ other: AnnotatedMoveTree) throws {
        guard FEN.placement(from: initialFEN) == FEN.placement(from: other.initialFEN),
              Position(fen: initialFEN)?.playerTurn == Position(fen: other.initialFEN)?.playerTurn else {
            throw AnnotatedMoveTreeError.differentInitialPosition
        }
        initialAnnotations.merge(other.initialAnnotations)
        Self.merge(other.children, into: &children)
    }

    private static func merge(_ source: [AnnotatedMoveNode], into target: inout [AnnotatedMoveNode]) {
        for node in source {
            if let index = target.firstIndex(where: { $0.move == node.move }) {
                target[index].annotations.merge(node.annotations)
                merge(node.children, into: &target[index].children)
            } else {
                target.append(node)
            }
        }
    }

    private mutating func reorder(parent: MovePath, _ body: (inout [AnnotatedMoveNode]) -> Void) {
        if parent.isRoot {
            body(&children)
        } else {
            Self.mutate(&children, parent.components[...]) { nodes, index in
                body(&nodes[index].children)
            }
        }
    }

    /// Walks `path` and calls `body` with the array that holds the last node
    /// and its index, mutating in place.
    @discardableResult
    private static func mutate(
        _ nodes: inout [AnnotatedMoveNode],
        _ path: ArraySlice<Int>,
        _ body: (inout [AnnotatedMoveNode], Int) -> Void
    ) -> Bool {
        guard let index = path.first, nodes.indices.contains(index) else { return false }
        if path.count == 1 {
            body(&nodes, index)
            return true
        }
        return mutate(&nodes[index].children, path.dropFirst(), body)
    }
}
