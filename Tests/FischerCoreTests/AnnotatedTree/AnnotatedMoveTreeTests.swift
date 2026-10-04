import Foundation
import Testing
@testable import FischerCore

struct AnnotatedMoveTreeTests {
    @Test("Inserting moves builds main line and variations")
    func insertBuildsTree() throws {
        var tree = AnnotatedMoveTree()
        let e4 = try tree.insert(san: "e4", at: .root)
        let e5 = try tree.insert(san: "e5", at: e4)
        let c5 = try tree.insert(san: "c5", at: e4)
        #expect(e4 == [0])
        #expect(e5 == [0, 0])
        #expect(c5 == [0, 1])
        let again = try tree.insert(san: "c5", at: e4)
        #expect(again == c5)
        #expect(tree.nodeCount == 3)
        #expect(tree.node(at: c5)?.numberedSAN == "1... c5")
        #expect(tree.variations(after: e4).map(\.path) == [c5])
        #expect(tree.siblings(of: c5).count == 2)
        #expect(tree.mainlineEnd() == e5)
        #expect(tree.nextMainlinePath(from: e4) == e5)
        #expect(tree.nextMainlinePath(from: e5) == nil)
    }

    @Test("Inserting rejects illegal moves and missing paths")
    func insertErrors() throws {
        var tree = AnnotatedMoveTree()
        #expect(throws: AnnotatedMoveTreeError.illegalMove(.notFound)) {
            try tree.insert(san: "e5", at: .root)
        }
        #expect(throws: AnnotatedMoveTreeError.invalidPath([3])) {
            try tree.insert(san: "e4", at: [3])
        }
        #expect(throws: AnnotatedMoveTreeError.illegalMove(.illegal)) {
            try tree.insert(ResolvedMove(move: .e2 >>> .e5), at: .root)
        }
    }

    @Test("Spanish input and promotion default to queen")
    func insertSpanishAndPromotion() throws {
        var tree = AnnotatedMoveTree()
        let nf3 = try tree.insert(san: "Cf3", language: .spanish, at: .root)
        #expect(tree.node(at: nf3)?.san.description == "Nf3")

        var promotion = try AnnotatedMoveTree(initialFEN: "8/4P3/8/8/8/k7/8/K7 w - - 0 1")
        let queen = try promotion.insert(ResolvedMove(move: .e7 >>> .e8), at: .root)
        let knight = try promotion.insert(ResolvedMove(move: .e7 >>> .e8, promotion: .knight), at: .root)
        #expect(promotion.node(at: queen)?.san.description == "e8=Q")
        #expect(promotion.node(at: knight)?.san.description == "e8=N")
        #expect(knight == [1])
    }

    @Test("Promote, demote and make main line reorder variations")
    func reorderVariations() throws {
        var tree = AnnotatedMoveTree()
        let e4 = try tree.insert(san: "e4", at: .root)
        _ = try tree.insert(san: "e5", at: e4)
        _ = try tree.insert(san: "c5", at: e4)
        let e6 = try tree.insert(san: "e6", at: e4)
        let nf3 = try tree.insert(san: "Nf3", at: e6)

        let promoted = tree.promote(at: e6)
        #expect(promoted == [0, 1])
        #expect(tree.children(at: e4).map(\.san.description) == ["e5", "e6", "c5"])
        let demoted = tree.demote(at: [0, 1])
        #expect(demoted == [0, 2])
        let demotedLast = tree.demote(at: [0, 2])
        #expect(demotedLast == nil)
        let promotedFirst = tree.promote(at: [0, 0])
        #expect(promotedFirst == nil)

        let newPath = tree.makeMainline(at: [0, 2, 0])
        #expect(newPath == [0, 0, 0])
        #expect(tree.mainline.map(\.node.san.description) == ["e4", "e6", "Nf3"])
        _ = nf3
    }

    @Test("Deleting nodes and continuations")
    func deleteNodes() throws {
        var tree = AnnotatedMoveTree()
        let line = tree.insertLine(uci: ["e2e4", "e7e5", "g1f3", "b8c6"], at: .root)
        #expect(line == [0, 0, 0, 0])
        _ = try tree.insert(san: "Nf6", at: [0, 0, 0])
        let deleted = tree.delete(at: [0, 0, 0, 1])
        #expect(deleted == [0, 0, 0])
        #expect(tree.children(at: [0, 0, 0]).count == 1)
        let truncated = tree.deleteContinuation(after: [0])
        #expect(truncated)
        #expect(tree.nodeCount == 1)
        let missing = tree.delete(at: [5])
        #expect(missing == nil)
        let root = tree.delete(at: [0])
        #expect(root == .root)
        #expect(tree.isEmpty)
    }

    @Test("Annotations can be edited by path")
    func editAnnotations() throws {
        var tree = AnnotatedMoveTree()
        let e4 = try tree.insert(san: "e4", at: .root)
        let updated = tree.updateAnnotations(at: e4) { annotations in
            annotations.toggle(.goodMove)
            annotations.toggle(.veryGoodMove)
            annotations.toggle(.whiteSlightAdvantage)
            annotations.commentText = "  Best   by test "
            annotations.toggleSquare(.e4, color: .green)
            annotations.toggleArrow(from: .d2, to: .d4, color: .red)
            annotations.clock = "0:05:00"
        }
        #expect(updated)
        let annotations = try #require(tree.annotations(at: e4))
        #expect(annotations.nags == [.veryGoodMove, .whiteSlightAdvantage])
        #expect(annotations.moveAssessment == .veryGoodMove)
        #expect(annotations.positionAssessment == .whiteSlightAdvantage)
        #expect(annotations.comments == ["Best by test"])
        #expect(annotations.pgnComments.contains(.clockTime("0:05:00")))
        let setMissing = tree.setAnnotations(MoveAnnotations(), at: [4])
        #expect(!setMissing)

        var toggled = annotations
        toggled.toggleSquare(.e4, color: .green)
        toggled.toggleArrow(from: .d2, to: .d4, color: .green)
        #expect(toggled.squares.isEmpty)
        #expect(toggled.arrows == [PGNArrow(color: .green, fromSquare: .d2, toSquare: .d4)])
    }

    @Test("Replaying positions and lines along a path")
    func replayAlongPath() throws {
        var tree = AnnotatedMoveTree()
        let inserted = tree.insertLine(uci: ["e2e4", "c7c5", "g1f3"], at: .root)
        let path = try #require(inserted)
        #expect(tree.uciLine(through: path) == ["e2e4", "c7c5", "g1f3"])
        #expect(tree.fen(at: path) == "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")
        #expect(tree.game(at: [1]) == nil)
        #expect(tree.path(forUCI: ["e2e4", "c7c5"]) == [0, 0])
        #expect(tree.path(forUCI: ["d2d4"]) == nil)
        #expect(tree.line(through: path).map(\.node.numberedSAN) == ["1. e4", "1... c5", "2. Nf3"])
        #expect(tree.clamp([0, 0, 0, 3, 1]) == [0, 0, 0])
    }

    @Test("Tree from a game uses its history as main line")
    func treeFromGame() throws {
        let game = try Game(sanMoves: ["d4", "d5", "c4", "e6"])
        let tree = AnnotatedMoveTree(game: game)
        #expect(tree.mainline.map(\.node.san.description) == ["d4", "d5", "c4", "e6"])

        let fromFEN = try Game(initialFEN: "4k3/8/8/8/8/K7/1p6/8 b - - 0 50", sanMoves: ["b1=N", "Kb3"])
        let fenTree = AnnotatedMoveTree(game: fromFEN)
        #expect(!fenTree.startsFromStandardPosition)
        #expect(fenTree.mainline.map(\.node.numberedSAN) == ["50... b1=N+", "51. Kb3"])
    }

    @Test("All lines enumerate every leaf for repertoire training")
    func allLines() throws {
        var tree = AnnotatedMoveTree()
        tree.insertLine(uci: ["e2e4", "e7e5", "g1f3"], at: .root)
        tree.insertLine(uci: ["c7c5", "g1f3"], at: [0])
        tree.insertLine(uci: ["d2d4"], at: .root)
        let lines = tree.allLines.map { $0.map(\.node.san.description) }
        #expect(lines == [["e4", "e5", "Nf3"], ["e4", "c5", "Nf3"], ["d4"]])
        #expect(tree.allReferences.count == tree.nodeCount)
    }

    @Test("Merging trees combines lines and annotations")
    func mergeTrees() throws {
        var first = AnnotatedMoveTree()
        first.insertLine(uci: ["e2e4", "e7e5"], at: .root)
        first.updateAnnotations(at: [0]) { $0.comments = ["King pawn"] }

        var second = AnnotatedMoveTree()
        second.insertLine(uci: ["e2e4", "c7c5"], at: .root)
        second.updateAnnotations(at: [0]) { $0.nags = [.goodMove] }

        try first.merge(second)
        #expect(first.children(at: [0]).map(\.san.description) == ["e5", "c5"])
        #expect(first.annotations(at: [0])?.comments == ["King pawn"])
        #expect(first.annotations(at: [0])?.nags == [.goodMove])

        let other = try AnnotatedMoveTree(initialFEN: "8/4P3/8/8/8/k7/8/K7 w - - 0 1")
        #expect(throws: AnnotatedMoveTreeError.differentInitialPosition) {
            try first.merge(other)
        }
    }

    @Test("Move paths")
    func movePaths() throws {
        let path: MovePath = [0, 2, 0]
        #expect(path.depth == 3)
        #expect(!path.isMainline)
        #expect(MovePath.mainline(plies: 2) == [0, 0])
        #expect(path.parent == [0, 2])
        #expect(path.hasPrefix([0, 2]))
        #expect(!path.hasPrefix([1]))
        #expect(path.commonAncestor(with: [0, 2, 1, 0]) == [0, 2])
        #expect(path.identifier == "move-0-2-0")
        #expect(MovePath.root.identifier == "move-root")
        #expect(MovePath.root.parent == nil)
        let data = try JSONEncoder().encode(path)
        #expect(String(decoding: data, as: UTF8.self) == "[0,2,0]")
        #expect(try JSONDecoder().decode(MovePath.self, from: data) == path)
    }

    @Test("Evaluations and clocks are parsed")
    func evaluationAndClock() {
        #expect(PGNEvaluation("#-3") == .mate(-3))
        #expect(PGNEvaluation("-1.25,22") == .pawns(-1.25))
        #expect(PGNEvaluation("abc") == nil)
        #expect(MoveAnnotations(clock: "1:02:03").clockSeconds == 3723)
        #expect(MoveAnnotations(clock: "0:00:59.5").clockSeconds == 59.5)
        #expect(MoveAnnotations(elapsedMoveTime: "0:00:07").elapsedMoveSeconds == 7)
        #expect(MoveAnnotations(clock: "x").clockSeconds == nil)
    }
}
