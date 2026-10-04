import Foundation
import Testing

enum TestResources {
    static func text(_ name: String, extension fileExtension: String = "pgn") throws -> String {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: fileExtension))
        return try String(contentsOf: url, encoding: .utf8)
    }

    static func data(_ name: String, extension fileExtension: String = "pgn") throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: fileExtension))
        return try Data(contentsOf: url)
    }
}
