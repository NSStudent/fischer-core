//
//  CommentListParserTests.swift
//  FischerCore
//
//  Created by Codex on 15/5/26.
//

import Parsing
import Testing
@testable import FischerCore

struct CommentListParserTests {
    @Test("Parses adjacent CSL and CAL annotations followed by text")
    func parsesAdjacentSquareAndArrowAnnotationsWithText() throws {
        let comments = try CommentListParser().parse(
            "{[%csl Rh7][%cal Gd3h7,Gh2h7] amenazando mate!}"
        )

        #expect(comments == [
            .squareList([
                PGNSquare(color: .red, square: .h7),
            ]),
            .arrowList([
                PGNArrow(color: .green, fromSquare: .d3, toSquare: .h7),
                PGNArrow(color: .green, fromSquare: .h2, toSquare: .h7),
            ]),
            .text("amenazando mate!"),
        ])
    }

    @Test("Parses adjacent annotations with multiple arrows and long text")
    func parsesAdjacentAnnotationsWithMultipleArrowsAndLongText() throws {
        let comments = try CommentListParser().parse(
            "{[%csl Gg3][%cal Gd1h1,Gg4g5,Rf4h6,Gc3e2,Ge2g3] con una ventaja clara. Plan: Th1-Ce2 y Cg3-g5.}"
        )

        #expect(comments == [
            .squareList([
                PGNSquare(color: .green, square: .g3),
            ]),
            .arrowList([
                PGNArrow(color: .green, fromSquare: .d1, toSquare: .h1),
                PGNArrow(color: .green, fromSquare: .g4, toSquare: .g5),
                PGNArrow(color: .red, fromSquare: .f4, toSquare: .h6),
                PGNArrow(color: .green, fromSquare: .c3, toSquare: .e2),
                PGNArrow(color: .green, fromSquare: .e2, toSquare: .g3),
            ]),
            .text("con una ventaja clara. Plan: Th1-Ce2 y Cg3-g5."),
        ])
    }

    @Test("Preserves adjacent CSL and CAL annotations without text")
    func parsesAdjacentSquareAndArrowAnnotationsWithoutText() throws {
        let comments = try CommentListParser().parse(
            "{ [%csl Gf6][%cal Bg8f6,Yd7f6] }"
        )

        #expect(comments == [
            .squareList([
                PGNSquare(color: .green, square: .f6),
            ]),
            .arrowList([
                PGNArrow(color: .blue, fromSquare: .g8, toSquare: .f6),
                PGNArrow(color: .yellow, fromSquare: .d7, toSquare: .f6),
            ]),
        ])
    }

    @Test("Parses CSL and CAL annotations separated by whitespace without text")
    func parsesSquareAndArrowAnnotationsSeparatedByWhitespaceWithoutText() throws {
        let comments = try CommentListParser().parse(
            "{[%csl Rg4] [%cal Ge5g4]}"
        )

        #expect(comments == [
            .squareList([
                PGNSquare(color: .red, square: .g4),
            ]),
            .arrowList([
                PGNArrow(color: .green, fromSquare: .e5, toSquare: .g4),
            ]),
        ])
    }

    @Test("PGN game parser keeps adjacent annotations and text in move comments")
    func pgnGameParserKeepsAdjacentAnnotationsAndTextInMoveComments() throws {
        let input =
        """
        [Event "Mixed comment annotations"]
        [Site "Local"]
        [Date "2026.05.15"]
        [Round "-"]
        [White "-"]
        [Black "-"]
        [Result "*"]

        1. e4 {[%csl Rh7][%cal Gd3h7,Gh2h7] amenazando mate!} *
        """

        let game = try PGNGameParser().parse(input)

        #expect(game.elements[0].postWhiteCommentList == [
            .squareList([
                PGNSquare(color: .red, square: .h7),
            ]),
            .arrowList([
                PGNArrow(color: .green, fromSquare: .d3, toSquare: .h7),
                PGNArrow(color: .green, fromSquare: .h2, toSquare: .h7),
            ]),
            .text("amenazando mate!"),
        ])
    }

    @Test("PGN game parser keeps whitespace-separated annotations in move comments")
    func pgnGameParserKeepsWhitespaceSeparatedAnnotationsInMoveComments() throws {
        let input =
        """
        [Event "Whitespace separated comment annotations"]
        [Site "Local"]
        [Date "2026.05.15"]
        [Round "-"]
        [White "-"]
        [Black "-"]
        [Result "*"]

        12. Ne5 {[%csl Rg4] [%cal Ge5g4]} *
        """

        let game = try PGNGameParser().parse(input)

        #expect(game.elements[0].postWhiteCommentList == [
            .squareList([
                PGNSquare(color: .red, square: .g4),
            ]),
            .arrowList([
                PGNArrow(color: .green, fromSquare: .e5, toSquare: .g4),
            ]),
        ])
    }
}
