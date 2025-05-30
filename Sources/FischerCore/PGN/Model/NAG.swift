//
//  Nag.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//

/// Represents a Numeric Annotation Glyph (NAG) used in chess PGN to evaluate moves.
///
/// NAGs provide a standardized way to annotate chess moves with commentary such as
/// "good move", "poor move", "decisive advantage", and more.
///
/// These annotations are widely used in PGN notation with symbols like `!`, `?`, `!?`, `+−`, etc.,
/// and help engines and humans alike understand the quality of a move.
///
/// - Reference: [PGN Standard - NAG codes](https://en.wikipedia.org/wiki/Numeric_Annotation_Glyphs)
public enum NAG: Int, CaseIterable, Equatable {
    case nullAnnotation = 0
    case goodMove
    case poorMove
    case veryGoodMove
    case veryPoorMove
    case speculativeMove
    case questionableMove
    case forcedMove
    case singularMove
    case worstMove
    case drawishPosition
    case equalChancesQuiet
    case equalChancesActive
    case unclearPosition
    case whiteSlightAdvantage
    case blackSlightAdvantage
    case whiteModerateAdvantage
    case blackModerateAdvantage
    case whiteDecisiveAdvantage
    case blackDecisiveAdvantage
    case whiteCrushingAdvantage
    case blackCrushingAdvantage
    case whiteZugzwang
    case blackZugzwang
    case whiteSlightSpace
    case blackSlightSpace
    case whiteModerateSpace
    case blackModerateSpace
    case whiteDecisiveSpace
    case blackDecisiveSpace
    case whiteSlightTime
    case blackSlightTime
    case whiteModerateTime
    case blackModerateTime
    case whiteDecisiveTime
    case blackDecisiveTime
    case whiteInitiative
    case blackInitiative
    case whiteLastingInitiative
    case blackLastingInitiative
    case whiteAttack
    case blackAttack
    case whiteInsufficientCompensation
    case blackInsufficientCompensation
    case whiteSufficientCompensation
    case blackSufficientCompensation
    case whiteMoreThanAdequateCompensation
    case blackMoreThanAdequateCompensation
    case whiteSlightCenterControl
    case blackSlightCenterControl
    case whiteModerateCenterControl
    case blackModerateCenterControl
    case whiteDecisiveCenterControl
    case blackDecisiveCenterControl
    case whiteSlightKingsideControl
    case blackSlightKingsideControl
    case whiteModerateKingsideControl
    case blackModerateKingsideControl
    case whiteDecisiveKingsideControl
    case blackDecisiveKingsideControl
    case whiteSlightQueensideControl
    case blackSlightQueensideControl
    case whiteModerateQueensideControl
    case blackModerateQueensideControl
    case whiteDecisiveQueensideControl
    case blackDecisiveQueensideControl
    case whiteVulnerableFirstRank
    case blackVulnerableFirstRank
    case whiteProtectedFirstRank
    case blackProtectedFirstRank
    case whitePoorKingSafety
    case blackPoorKingSafety
    case whiteGoodKingSafety
    case blackGoodKingSafety
    case whitePoorKingPlacement
    case blackPoorKingPlacement
    case whiteGoodKingPlacement
    case blackGoodKingPlacement
    case whiteVeryWeakPawnStructure
    case blackVeryWeakPawnStructure
    case whiteModeratelyWeakPawnStructure
    case blackModeratelyWeakPawnStructure
    case whiteModeratelyStrongPawnStructure
    case blackModeratelyStrongPawnStructure
    case whiteVeryStrongPawnStructure
    case blackVeryStrongPawnStructure
    case whitePoorKnightPlacement
    case blackPoorKnightPlacement
    case whiteGoodKnightPlacement
    case blackGoodKnightPlacement
    case whitePoorBishopPlacement
    case blackPoorBishopPlacement
    case whiteGoodBishopPlacement
    case blackGoodBishopPlacement
    case whitePoorRookPlacement
    case blackPoorRookPlacement
    case whiteGoodRookPlacement
    case blackGoodRookPlacement
    case whitePoorQueenPlacement
    case blackPoorQueenPlacement
    case whiteGoodQueenPlacement
    case blackGoodQueenPlacement
    case whitePoorCoordination
    case blackPoorCoordination
    case whiteGoodCoordination
    case blackGoodCoordination
    case whiteVeryPoorOpening
    case blackVeryPoorOpening
    case whitePoorOpening
    case blackPoorOpening
    case whiteGoodOpening
    case blackGoodOpening
    case whiteVeryGoodOpening
    case blackVeryGoodOpening
    case whiteVeryPoorMiddlegame
    case blackVeryPoorMiddlegame
    case whitePoorMiddlegame
    case blackPoorMiddlegame
    case whiteGoodMiddlegame
    case blackGoodMiddlegame
    case whiteVeryGoodMiddlegame
    case blackVeryGoodMiddlegame
    case whiteVeryPoorEndgame
    case blackVeryPoorEndgame
    case whitePoorEndgame
    case blackPoorEndgame
    case whiteGoodEndgame
    case blackGoodEndgame
    case whiteVeryGoodEndgame
    case blackVeryGoodEndgame
    case whiteSlightCounterplay
    case blackSlightCounterplay
    case whiteModerateCounterplay
    case blackModerateCounterplay
    case whiteDecisiveCounterplay
    case blackDecisiveCounterplay
    case whiteModerateTimePressure
    case blackModerateTimePressure
    case whiteSevereTimePressure
    case blackSevereTimePressure
    
    public var symbol: String {
        switch self {
        case .nullAnnotation: return ""
        case .goodMove: return "!"
        case .poorMove: return "?"
        case .veryGoodMove: return "!!"
        case .veryPoorMove: return "??"
        case .speculativeMove: return "!?"
        case .questionableMove: return "?!"
        case .forcedMove: return "□"
        case .singularMove: return "⟳"
        case .worstMove: return "??"
        case .drawishPosition: return "="
        case .equalChancesQuiet: return "="
        case .equalChancesActive: return "="
        case .unclearPosition: return "∞"
        case .whiteSlightAdvantage: return "+="
        case .blackSlightAdvantage: return "=-"
        case .whiteModerateAdvantage: return "+/-"
        case .blackModerateAdvantage: return "-/+"
        case .whiteDecisiveAdvantage: return "+-"
        case .blackDecisiveAdvantage: return "-+"
        case .whiteCrushingAdvantage: return "+−"
        case .blackCrushingAdvantage: return "−+"
        case .whiteZugzwang: return "Z"
        case .blackZugzwang: return "Z"
        default: return ""
        }
    }
}

//extension NAG: CustomStringConvertible {
//    var description: String {
//        switch self {
//        case .nullAnnotation:
//            return "nullAnnotation"
//        case .goodMove:
//            return "goodMove"
//        case .poorMove:
//            return "poorMove"
//        case .veryGoodMove:
//            return "veryGoodMove"
//        case .veryPoorMove:
//            return "veryPoorMove"
//        case .speculativeMove:
//            return "speculativeMove"
//        case .questionableMove:
//            return "questionableMove"
//        case .forcedMove:
//            return "forcedMove"
//        case .singularMove:
//            return "singularMove"
//        case .worstMove:
//            return "worstMove"
//        case .drawishPosition:
//            return "drawishPosition"
//        case .equalChancesQuiet:
//            return "equalChancesQuiet"
//        case .equalChancesActive:
//            return "equalChancesActive"
//        case .unclearPosition:
//            return "unclearPosition"
//        case .whiteSlightAdvantage:
//            return "whiteSlightAdvantage"
//        case .blackSlightAdvantage:
//            return "blackSlightAdvantage"
//        case .whiteModerateAdvantage:
//            return "whiteModerateAdvantage"
//        case .blackModerateAdvantage:
//            return "blackModerateAdvantage"
//        case .whiteDecisiveAdvantage:
//            return "whiteDecisiveAdvantage"
//        case .blackDecisiveAdvantage:
//            return "blackDecisiveAdvantage"
//        case .whiteCrushingAdvantage:
//            return "whiteCrushingAdvantage"
//        case .blackCrushingAdvantage:
//            return "blackCrushingAdvantage"
//        case .whiteZugzwang:
//            return "whiteZugzwang"
//        case .blackZugzwang:
//            return "blackZugzwang"
//        case .whiteSlightSpace:
//            return "whiteSlightSpace"
//        case .blackSlightSpace:
//            return "blackSlightSpace"
//        case .whiteModerateSpace:
//            return "whiteModerateSpace"
//        case .blackModerateSpace:
//            return "blackModerateSpace"
//        case .whiteDecisiveSpace:
//            return "whiteDecisiveSpace"
//        case .blackDecisiveSpace:
//            return "blackDecisiveSpace"
//        case .whiteSlightTime:
//            return "whiteSlightTime"
//        case .blackSlightTime:
//            return "blackSlightTime"
//        case .whiteModerateTime:
//            return "whiteModerateTime"
//        case .blackModerateTime:
//            return "blackModerateTime"
//        case .whiteDecisiveTime:
//            return "whiteDecisiveTime"
//        case .blackDecisiveTime:
//            return "blackDecisiveTime"
//        case .whiteInitiative:
//            return "whiteInitiative"
//        case .blackInitiative:
//            return "blackInitiative"
//        case .whiteLastingInitiative:
//            return "whiteLastingInitiative"
//        case .blackLastingInitiative:
//            return "blackLastingInitiative"
//        case .whiteAttack:
//            return "whiteAttack"
//        case .blackAttack:
//            return "blackAttack"
//        case .whiteInsufficientCompensation:
//            return "whiteInsufficientCompensation"
//        case .blackInsufficientCompensation:
//            return "blackInsufficientCompensation"
//        case .whiteSufficientCompensation:
//            return "whiteSufficientCompensation"
//        case .blackSufficientCompensation:
//            return "blackSufficientCompensation"
//        case .whiteMoreThanAdequateCompensation:
//            return "whiteMoreThanAdequateCompensation"
//        case .blackMoreThanAdequateCompensation:
//            return "blackMoreThanAdequateCompensation"
//        case .whiteSlightCenterControl:
//            return "whiteSlightCenterControl"
//        case .blackSlightCenterControl:
//            return "blackSlightCenterControl"
//        case .whiteModerateCenterControl:
//            return "whiteModerateCenterControl"
//        case .blackModerateCenterControl:
//            return "blackModerateCenterControl"
//        case .whiteDecisiveCenterControl:
//            return "whiteDecisiveCenterControl"
//        case .blackDecisiveCenterControl:
//            return "blackDecisiveCenterControl"
//        case .whiteSlightKingsideControl:
//            return "whiteSlightKingsideControl"
//        case .blackSlightKingsideControl:
//            return "blackSlightKingsideControl"
//        case .whiteModerateKingsideControl:
//            return "whiteModerateKingsideControl"
//        case .blackModerateKingsideControl:
//            return "blackModerateKingsideControl"
//        case .whiteDecisiveKingsideControl:
//            return "whiteDecisiveKingsideControl"
//        case .blackDecisiveKingsideControl:
//            return "blackDecisiveKingsideControl"
//        case .whiteSlightQueensideControl:
//            return "whiteSlightQueensideControl"
//        case .blackSlightQueensideControl:
//            return "blackSlightQueensideControl"
//        case .whiteModerateQueensideControl:
//            return "whiteModerateQueensideControl"
//        case .blackModerateQueensideControl:
//            return "blackModerateQueensideControl"
//        case .whiteDecisiveQueensideControl:
//            return "whiteDecisiveQueensideControl"
//        case .blackDecisiveQueensideControl:
//            return "blackDecisiveQueensideControl"
//        case .whiteVulnerableFirstRank:
//            return "whiteVulnerableFirstRank"
//        case .blackVulnerableFirstRank:
//            return "blackVulnerableFirstRank"
//        case .whiteProtectedFirstRank:
//            return "whiteProtectedFirstRank"
//        case .blackProtectedFirstRank:
//            return "blackProtectedFirstRank"
//        case .whitePoorKingSafety:
//            return "whitePoorKingSafety"
//        case .blackPoorKingSafety:
//            return "blackPoorKingSafety"
//        case .whiteGoodKingSafety:
//            return "whiteGoodKingSafety"
//        case .blackGoodKingSafety:
//            return "blackGoodKingSafety"
//        case .whitePoorKingPlacement:
//            return "whitePoorKingPlacement"
//        case .blackPoorKingPlacement:
//            return "blackPoorKingPlacement"
//        case .whiteGoodKingPlacement:
//            return "whiteGoodKingPlacement"
//        case .blackGoodKingPlacement:
//            return "blackGoodKingPlacement"
//        case .whiteVeryWeakPawnStructure:
//            return "whiteVeryWeakPawnStructure"
//        case .blackVeryWeakPawnStructure:
//            return "blackVeryWeakPawnStructure"
//        case .whiteModeratelyWeakPawnStructure:
//            return "whiteModeratelyWeakPawnStructure"
//        case .blackModeratelyWeakPawnStructure:
//            return "blackModeratelyWeakPawnStructure"
//        case .whiteModeratelyStrongPawnStructure:
//            return "whiteModeratelyStrongPawnStructure"
//        case .blackModeratelyStrongPawnStructure:
//            return "blackModeratelyStrongPawnStructure"
//        case .whiteVeryStrongPawnStructure:
//            return "whiteVeryStrongPawnStructure"
//        case .blackVeryStrongPawnStructure:
//            return "blackVeryStrongPawnStructure"
//        case .whitePoorKnightPlacement:
//            return "whitePoorKnightPlacement"
//        case .blackPoorKnightPlacement:
//            return "blackPoorKnightPlacement"
//        case .whiteGoodKnightPlacement:
//            return "whiteGoodKnightPlacement"
//        case .blackGoodKnightPlacement:
//            return "blackGoodKnightPlacement"
//        case .whitePoorBishopPlacement:
//            return "whitePoorBishopPlacement"
//        case .blackPoorBishopPlacement:
//            return "blackPoorBishopPlacement"
//        case .whiteGoodBishopPlacement:
//            return "whiteGoodBishopPlacement"
//        case .blackGoodBishopPlacement:
//            return "blackGoodBishopPlacement"
//        case .whitePoorRookPlacement:
//            return "whitePoorRookPlacement"
//        case .blackPoorRookPlacement:
//            return "blackPoorRookPlacement"
//        case .whiteGoodRookPlacement:
//            return "whiteGoodRookPlacement"
//        case .blackGoodRookPlacement:
//            return "blackGoodRookPlacement"
//        case .whitePoorQueenPlacement:
//            return "whitePoorQueenPlacement"
//        case .blackPoorQueenPlacement:
//            return "blackPoorQueenPlacement"
//        case .whiteGoodQueenPlacement:
//            return "whiteGoodQueenPlacement"
//        case .blackGoodQueenPlacement:
//            return "blackGoodQueenPlacement"
//        case .whitePoorCoordination:
//            return "whitePoorCoordination"
//        case .blackPoorCoordination:
//            return "blackPoorCoordination"
//        case .whiteGoodCoordination:
//            return "whiteGoodCoordination"
//        case .blackGoodCoordination:
//            return "blackGoodCoordination"
//        case .whiteVeryPoorOpening:
//            return "whiteVeryPoorOpening"
//        case .blackVeryPoorOpening:
//            return "blackVeryPoorOpening"
//        case .whitePoorOpening:
//            return "whitePoorOpening"
//        case .blackPoorOpening:
//            return "blackPoorOpening"
//        case .whiteGoodOpening:
//            return "whiteGoodOpening"
//        case .blackGoodOpening:
//            return "blackGoodOpening"
//        case .whiteVeryGoodOpening:
//            return "whiteVeryGoodOpening"
//        case .blackVeryGoodOpening:
//            return "blackVeryGoodOpening"
//        case .whiteVeryPoorMiddlegame:
//            return "whiteVeryPoorMiddlegame"
//        case .blackVeryPoorMiddlegame:
//            return "blackVeryPoorMiddlegame"
//        case .whitePoorMiddlegame:
//            return "whitePoorMiddlegame"
//        case .blackPoorMiddlegame:
//            return "blackPoorMiddlegame"
//        case .whiteGoodMiddlegame:
//            return "whiteGoodMiddlegame"
//        case .blackGoodMiddlegame:
//            return "blackGoodMiddlegame"
//        case .whiteVeryGoodMiddlegame:
//            return "whiteVeryGoodMiddlegame"
//        case .blackVeryGoodMiddlegame:
//            return "blackVeryGoodMiddlegame"
//        case .whiteVeryPoorEndgame:
//            return "whiteVeryPoorEndgame"
//        case .blackVeryPoorEndgame:
//            return "blackVeryPoorEndgame"
//        case .whitePoorEndgame:
//            return "whitePoorEndgame"
//        case .blackPoorEndgame:
//            return "blackPoorEndgame"
//        case .whiteGoodEndgame:
//            return "whiteGoodEndgame"
//        case .blackGoodEndgame:
//            return "blackGoodEndgame"
//        case .whiteVeryGoodEndgame:
//            return "whiteVeryGoodEndgame"
//        case .blackVeryGoodEndgame:
//            return "blackVeryGoodEndgame"
//        case .whiteSlightCounterplay:
//            return "whiteSlightCounterplay"
//        case .blackSlightCounterplay:
//            return "blackSlightCounterplay"
//        case .whiteModerateCounterplay:
//            return "whiteModerateCounterplay"
//        case .blackModerateCounterplay:
//            return "blackModerateCounterplay"
//        case .whiteDecisiveCounterplay:
//            return "whiteDecisiveCounterplay"
//        case .blackDecisiveCounterplay:
//            return "blackDecisiveCounterplay"
//        case .whiteModerateTimePressure:
//            return "whiteModerateTimePressure"
//        case .blackModerateTimePressure:
//            return "blackModerateTimePressure"
//        case .whiteSevereTimePressure:
//            return "whiteSevereTimePressure"
//        case .blackSevereTimePressure:
//            return "blackSevereTimePressure"
//        }
//    }
//}
