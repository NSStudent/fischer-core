import Testing
@testable import FischerCore

struct FastSANParserTests {
    private func composed(_ text: String) -> SANMove? {
        try? SanMoveParser().parse(text)
    }

    @Test("Fast parser matches the composed parser on crafted input")
    func matchesComposedParser() {
        let samples = [
            "e4", "exd5", "ed5", "xd5", "e8=Q", "exd8=N+", "e8=K", "e8=", "e8Q",
            "Nf3", "Nbd7", "N1c3", "Qh4e1", "Qh4xe1#", "Rxa8+", "Kxf7", "Bb5+", "Rdd1",
            "O-O", "O-O+", "O-O-O#", "O-O-O", "O-", "0-0", "o-o",
            "Z0", "--", "", "N", "Nz9", "Ni3", "e9", "a", "P", "Pe4", "K1e2", "Nf3+#", "Ng1f3",
            "b1=N+", "axb8=R", "h8", "Kxe8", "Rh1h3", "R1h3", "Rhh3", "Rxh3+", "bxa1=Q#"
        ]
        for sample in samples {
            #expect(FastSANParser.parse(sample) == composed(sample), "\(sample)")
        }
    }

    @Test("Fast parser matches the composed parser on every move of real games", arguments: ["wcup25-short", "twic1617-short"])
    func matchesOnRealGames(resource: String) throws {
        let text = try TestResources.text(resource)
        var checked = 0
        for chunk in PGNGameSplitter.split(text) {
            let movetext = chunk.components(separatedBy: "\n\n").dropFirst().joined(separator: " ")
            for token in movetext.split(whereSeparator: \.isWhitespace) {
                let san = token.drop { $0.isNumber || $0 == "." }
                guard let first = san.first, first.isLetter else { continue }
                let expected = composed(String(san))
                #expect(FastSANParser.parse(san) == expected, "\(san)")
                if expected != nil { checked += 1 }
            }
        }
        #expect(checked > 1_000)
    }
}

struct SANParserRegressionTests {
    @Test("Invalid rank disambiguation fails instead of crashing")
    func invalidRankDoesNotCrash() {
        #expect(throws: (any Error).self) { try SanMoveParser().parse("N9f3") }
        #expect(throws: (any Error).self) { try SANMove(san: "R0a1") }
    }
}

struct SquareParsingRegressionTests {
    @Test("Squares with an invalid rank return nil instead of crashing")
    func invalidRankSquare() {
        #expect(Square("e9") == nil)
        #expect(Square("a0") == nil)
        #expect(Square("e4") == .e4)
        #expect(throws: (any Error).self) { try SANMove(san: "e9") }
    }
}
