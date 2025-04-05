//
//  PGNGame.swift
//  FischerCore
//
//  Created by Omar Megdadi on 4/4/25.
//

struct PGNGame {
    public var tags: [PGNTag: String]
    public var initialComment: [PGNComment]?
    public var elements: [PGNElement]
    let result: PGNOutcome?
}

extension PGNGame: CustomStringConvertible {
    var description: String {
        let taglistDescription = tags
            .map { element in
                "\(element.0.rawValue) --> \(element.1)"
            }.joined(separator: "\n")
        let initialCommentDescription = initialComment?.map(\.description).joined(separator: "\n")
        let movementListDescription = elements
            .map{ element in
                element.description
            }.joined(separator: "\n")
        let resultDetail = "Result: \(result?.rawValue ?? "" ) \n"
        let gameDescription = [
            taglistDescription,
            initialCommentDescription,
            movementListDescription,
            resultDetail
        ].compactMap { $0 }.joined(separator: "\n")
        return """
        Game:
        \(gameDescription)
        """
    }
}
