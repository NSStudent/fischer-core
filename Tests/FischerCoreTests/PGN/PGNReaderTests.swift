import Foundation
import Testing
@testable import FischerCore

final class PGNReaderTests {
    @Test("TWIC file MoveTree PGN reader")
    func parseTWICFileToMoveTreePGN() async throws {
        let fileContents = try loadTWICFile()
        let result = try PGNReader().parse(fileContents)

        #expect(result.count == 159)
    }

    @Test("TWIC file MoveTree PGN reader matches PGN parser")
    func parseTWICFileToMoveTreePGNMatchingClassicParser() async throws {
        let fileContents = try loadTWICFile()

        let parserResult = try PGNParser().parse(fileContents)
        let readerResult = try PGNReader().parse(fileContents)

        #expect(readerResult.count == 159)
        #expect(readerResult == parserResult.games.map(\.moveTreePGN))
    }

    @Test("TWIC benchmark for PGN parsers")
    func benchmarkTWICParsers() async throws {
        let fileContents = try loadTWICFile()

        let classic = try benchmark(label: "PGNParser") {
            try PGNParser().parse(fileContents).games.count
        }
        let basic = try benchmark(label: "BasicPGNParser") {
            try BasicPGNParser().parse(fileContents).count
        }
        let moveTree = try benchmark(label: "PGNReader") {
            try PGNReader().parse(fileContents).count
        }

        #expect(classic.count == 159)
        #expect(basic.count == 159)
        #expect(moveTree.count == 159)

        print(
            """
            TWIC benchmark
            - \(classic.summary)
            - \(basic.summary)
            - \(moveTree.summary)
            """
        )
    }
}

private extension PGNReaderTests {
    func loadTWICFile() throws -> String {
        let fileURL = try #require(
            Bundle.module.url(forResource: "twic1618-short", withExtension: "pgn")
        )

        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    func benchmark(
        label: String,
        iterations: Int = 3,
        operation: () throws -> Int
    ) throws -> BenchmarkResult {
        var samples: [TimeInterval] = []
        var lastCount = 0

        for _ in 0..<iterations {
            let start = Date()
            lastCount = try operation()
            samples.append(Date().timeIntervalSince(start))
        }

        return BenchmarkResult(label: label, samples: samples, count: lastCount)
    }
}

private struct BenchmarkResult {
    let label: String
    let samples: [TimeInterval]
    let count: Int

    var summary: String {
        "\(label): avg \(samples.average.formattedSeconds), min \(samples.min()!.formattedSeconds), max \(samples.max()!.formattedSeconds)"
    }
}

private extension Array where Element == TimeInterval {
    var average: TimeInterval {
        reduce(0, +) / Double(count)
    }
}

private extension TimeInterval {
    var formattedSeconds: String {
        String(format: "%.3fs", self)
    }
}
