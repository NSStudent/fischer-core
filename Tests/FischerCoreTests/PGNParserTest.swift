//
//  PGNParserTest.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//
import Testing
@testable import FischerCore
import Parsing

class PGNParserTest {
    @Test("Parse tags collection")
    func parseTags() async throws {
        let tagsString = """
            [Event "F/S Return Match"]
            [Site "Belgrade, Serbia JUG"]
            [Date "1992.11.04"]
            [Round "29"]
            [White "Fischer, Robert J."]
            [Black "Spassky, Boris V."]
            [Result "1/2-1/2"]
            """
        
        let tagParse =  Parse {
            "["
            PrefixUpTo(" \"").map{Tag(rawValue: String($0)) }
            " \""
            Prefix{ $0 != "\""}
            "\"]"
        }
        
        let tagListParse = Many {
            tagParse
        } separator: {
            "\n"
        }
        let result = try tagListParse.parse(tagsString)
        print(result)
        #expect(result.count == 7)
    }
    
   
    
}
