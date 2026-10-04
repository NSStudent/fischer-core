//
//  MovePath.swift
//  FischerCore
//

/// The location of a node in an ``AnnotatedMoveTree``.
///
/// Each component is an index into the `children` of the previous level,
/// starting at the root. Index `0` is always the main continuation and higher
/// indices are variations. The number of components is the number of plies
/// played from the initial position, so the empty path (``root``) is the
/// initial position and `[0, 0, 0]` is the third ply of the main line.
public struct MovePath: Hashable, Sendable, Codable, CustomStringConvertible, ExpressibleByArrayLiteral {
    /// The child indices from the root.
    public var components: [Int]

    /// The initial position, before any move.
    public static let root = MovePath([])

    /// Creates a path from child indices.
    public init(_ components: [Int]) {
        self.components = components
    }

    public init(arrayLiteral elements: Int...) {
        self.components = elements
    }

    /// A main-line path of `plies` moves.
    public static func mainline(plies: Int) -> MovePath {
        MovePath(Array(repeating: 0, count: max(0, plies)))
    }

    /// Whether this is the initial position.
    public var isRoot: Bool { components.isEmpty }

    /// The number of plies from the initial position.
    public var depth: Int { components.count }

    /// Whether every step follows the main continuation.
    public var isMainline: Bool { components.allSatisfy { $0 == 0 } }

    /// The path of the previous position, or `nil` for the root.
    public var parent: MovePath? {
        isRoot ? nil : MovePath(Array(components.dropLast()))
    }

    /// The index of the node among its siblings, or `nil` for the root.
    public var lastIndex: Int? { components.last }

    /// The path of the child at `index`.
    public func appending(_ index: Int) -> MovePath {
        MovePath(components + [index])
    }

    /// The path of the main continuation of this node.
    public var mainContinuation: MovePath { appending(0) }

    /// Whether `prefix` is an ancestor of (or equal to) this path.
    public func hasPrefix(_ prefix: MovePath) -> Bool {
        components.count >= prefix.components.count
            && Array(components.prefix(prefix.components.count)) == prefix.components
    }

    /// The longest common ancestor of the two paths.
    public func commonAncestor(with other: MovePath) -> MovePath {
        var prefix: [Int] = []
        for (lhs, rhs) in zip(components, other.components) {
            guard lhs == rhs else { break }
            prefix.append(lhs)
        }
        return MovePath(prefix)
    }

    /// A stable string identifier, for example `"move-root"` or `"move-0-0-1"`.
    public var identifier: String {
        isRoot ? "move-root" : "move-" + components.map(String.init).joined(separator: "-")
    }

    public var description: String {
        "[" + components.map(String.init).joined(separator: ",") + "]"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.components = try container.decode([Int].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(components)
    }
}
