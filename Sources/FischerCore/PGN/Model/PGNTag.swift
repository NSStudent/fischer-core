//
//  PGNTag.swift
//  FischerCore
//
//  Created by Omar Megdadi on 1/4/25.
//

/// Represents the standardized PGN tags used in chess game notation.
/// PGN (Portable Game Notation) tags store metadata about chess games.
public enum PGNTag: Equatable, Hashable, RawRepresentable, Codable, CaseIterable {
    // MARK: - Known Tags
    /// Name of the event or tournament.
    case event
    /// Location where the game was played.
    case site
    /// Date the game was played.
    case date
    /// Round of the game within the event.
    case round
    /// Name of the player with white pieces.
    case white
    /// Name of the player with black pieces.
    case black
    /// Result of the game (e.g., 1-0, 0-1, 1/2-1/2, *).
    case result

    // MARK: - Supplemental Tags: Titles
    /// Title of the player with white pieces.
    case whiteTitle
    /// Title of the player with black pieces.
    case blackTitle

    // MARK: - Supplemental Tags: Elo Ratings
    /// Elo rating of the player with white pieces.
    case whiteElo
    /// Elo rating of the player with black pieces.
    case blackElo

    // MARK: - Supplemental Tags: USCF Ratings
    /// USCF rating of the player with white pieces.
    case whiteUSCF
    /// USCF rating of the player with black pieces.
    case blackUSCF

    // MARK: - Supplemental Tags: National IDs
    /// National ID of the player with white pieces.
    case whiteNA
    /// National ID of the player with black pieces.
    case blackNA

    // MARK: - Supplemental Tags: Player Type
    /// Type of the player with white pieces (e.g., human, computer).
    case whiteType
    /// Type of the player with black pieces (e.g., human, computer).
    case blackType

    // MARK: - Supplemental Tags: Event Metadata
    /// Date of the event.
    case eventDate
    /// Sponsor of the event.
    case eventSponsor
    /// Section of the event.
    case section
    /// Stage of the event.
    case stage
    /// Board number for the game.
    case board

    // MARK: - Supplemental Tags: Opening Information
    /// Opening played in the game.
    case opening
    /// Variation of the opening played.
    case variation
    /// Sub-variation of the opening played.
    case subVariation

    // MARK: - Supplemental Tags: ECO and NIC
    /// ECO code for the opening played.
    case eco
    /// NIC code for the opening played.
    case nic

    // MARK: - Supplemental Tags: Time Information
    /// Time for the game (local time field in some PGNs).
    case time
    /// UTC time the game was played.
    case utcTime
    /// UTC date the game was played.
    case UTCDate
    /// Time control format used in the game.
    case timeControl

    // MARK: - Supplemental Tags: Initial Setup
    /// Indicates if the game is set up from a starting position.
    case setUp
    /// FEN string representing the position of the game.
    case fen

    // MARK: - Supplemental Tags: Game Metadata
    /// Termination of the game (e.g., normal, abandoned).
    case termination
    /// Annotator of the game.
    case annotator
    /// Mode of the game (e.g., standard, rapid).
    case mode
    /// Total number of plies in the game.
    case plyCount

    // MARK: - Supplemental Tags: Variant Information
    /// Variant of the game being played (e.g., chess960).
    case variant
    /// Name of the study related to the game.
    case studyName
    /// Name of the chapter related to the game.
    case chapterName
    /// URL of the chapter.
    case chapterURL
    /// FIDE ID of the player with white pieces.
    case whiteFideId
    /// FIDE ID of the player with black pieces.
    case blackFideId

    /// Rating difference of the player with black pieces.
    case blackRatingDiff
    /// Rating difference of the player with white pieces.
    case whiteRatingDiff

    /// CurrentPosition used in some PGN exports (e.g., chess.com sharing).
    case currentPosition
    /// Timezone of the event/location.
    case timeZone
    /// URL pointing to ECO reference.
    case ecoUrl
    /// Start time of the game (alternative field found in some sites).
    case startTime
    /// End time of the game (alternative field found in some sites).
    case endTime
    /// End date of the game/event.
    case endDate
    /// Link to external resource for the game.
    case link
    /// URL related to the player with white pieces.
    case whiteUrl
    /// Country of the player with white pieces.
    case whiteCountry
    /// URL related to the player with black pieces.
    case blackUrl
    /// Country of the player with black pieces.
    case blackCountry

    /// Any unknown or custom tag preserved as-is.
    case custom(String)

    // MARK: - RawRepresentable
    public typealias RawValue = String

    public var rawValue: String {
        switch self {
        case .event: return "Event"
        case .site: return "Site"
        case .date: return "Date"
        case .round: return "Round"
        case .white: return "White"
        case .black: return "Black"
        case .result: return "Result"
        case .whiteTitle: return "WhiteTitle"
        case .blackTitle: return "BlackTitle"
        case .whiteElo: return "WhiteElo"
        case .blackElo: return "BlackElo"
        case .whiteUSCF: return "WhiteUSCF"
        case .blackUSCF: return "BlackUSCF"
        case .whiteNA: return "WhiteNA"
        case .blackNA: return "BlackNA"
        case .whiteType: return "WhiteType"
        case .blackType: return "BlackType"
        case .eventDate: return "EventDate"
        case .eventSponsor: return "EventSponsor"
        case .section: return "Section"
        case .stage: return "Stage"
        case .board: return "Board"
        case .opening: return "Opening"
        case .variation: return "Variation"
        case .subVariation: return "SubVariation"
        case .eco: return "ECO"
        case .nic: return "NIC"
        case .time: return "Time"
        case .utcTime: return "UTCTime"
        case .UTCDate: return "UTCDate"
        case .timeControl: return "TimeControl"
        case .setUp: return "SetUp"
        case .fen: return "FEN"
        case .termination: return "Termination"
        case .annotator: return "Annotator"
        case .mode: return "Mode"
        case .plyCount: return "PlyCount"
        case .variant: return "Variant"
        case .studyName: return "StudyName"
        case .chapterName: return "ChapterName"
        case .chapterURL: return "ChapterURL"
        case .whiteFideId: return "WhiteFideId"
        case .blackFideId: return "BlackFideId"
        case .blackRatingDiff: return "BlackRatingDiff"
        case .whiteRatingDiff: return "WhiteRatingDiff"
        case .currentPosition: return "CurrentPosition"
        case .timeZone: return "Timezone"
        case .ecoUrl: return "ECOUrl"
        case .startTime: return "StartTime"
        case .endTime: return "EndTime"
        case .endDate: return "EndDate"
        case .link: return "Link"
        case .whiteUrl: return "WhiteUrl"
        case .whiteCountry: return "WhiteCountry"
        case .blackUrl: return "BlackUrl"
        case .blackCountry: return "BlackCountry"
        case let .custom(key): return key
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "Event": self = .event
        case "Site": self = .site
        case "Date": self = .date
        case "Round": self = .round
        case "White": self = .white
        case "Black": self = .black
        case "Result": self = .result
        case "WhiteTitle": self = .whiteTitle
        case "BlackTitle": self = .blackTitle
        case "WhiteElo": self = .whiteElo
        case "BlackElo": self = .blackElo
        case "WhiteUSCF": self = .whiteUSCF
        case "BlackUSCF": self = .blackUSCF
        case "WhiteNA": self = .whiteNA
        case "BlackNA": self = .blackNA
        case "WhiteType": self = .whiteType
        case "BlackType": self = .blackType
        case "EventDate": self = .eventDate
        case "EventSponsor": self = .eventSponsor
        case "Section": self = .section
        case "Stage": self = .stage
        case "Board": self = .board
        case "Opening": self = .opening
        case "Variation": self = .variation
        case "SubVariation": self = .subVariation
        case "ECO": self = .eco
        case "NIC": self = .nic
        case "Time": self = .time
        case "UTCTime": self = .utcTime
        case "UTCDate": self = .UTCDate
        case "TimeControl": self = .timeControl
        case "SetUp": self = .setUp
        case "FEN": self = .fen
        case "Termination": self = .termination
        case "Annotator": self = .annotator
        case "Mode": self = .mode
        case "PlyCount": self = .plyCount
        case "Variant": self = .variant
        case "StudyName": self = .studyName
        case "ChapterName": self = .chapterName
        case "ChapterURL": self = .chapterURL
        case "WhiteFideId": self = .whiteFideId
        case "BlackFideId": self = .blackFideId
        case "BlackRatingDiff": self = .blackRatingDiff
        case "WhiteRatingDiff": self = .whiteRatingDiff
        case "CurrentPosition": self = .currentPosition
        case "Timezone": self = .timeZone
        case "ECOUrl": self = .ecoUrl
        case "StartTime": self = .startTime
        case "EndTime": self = .endTime
        case "EndDate": self = .endDate
        case "Link": self = .link
        case "WhiteUrl": self = .whiteUrl
        case "WhiteCountry": self = .whiteCountry
        case "BlackUrl": self = .blackUrl
        case "BlackCountry": self = .blackCountry
        default:
            self = .custom(rawValue)
        }
    }

    // MARK: - CaseIterable (manual)
    public static var allCases: [PGNTag] = [
        .event,
        .site,
        .date,
        .round,
        .white,
        .black,
        .result,
        .whiteTitle,
        .blackTitle,
        .whiteElo,
        .blackElo,
        .whiteUSCF,
        .blackUSCF,
        .whiteNA,
        .blackNA,
        .whiteType,
        .blackType,
        .eventDate,
        .eventSponsor,
        .section,
        .stage,
        .board,
        .opening,
        .variation,
        .subVariation,
        .eco,
        .nic,
        .time,
        .utcTime,
        .UTCDate,
        .timeControl,
        .setUp,
        .fen,
        .termination,
        .annotator,
        .mode,
        .plyCount,
        .variant,
        .studyName,
        .chapterName,
        .chapterURL,
        .whiteFideId,
        .blackFideId,
        .blackRatingDiff,
        .whiteRatingDiff,
        .currentPosition,
        .timeZone,
        .ecoUrl,
        .startTime,
        .endTime,
        .endDate,
        .link,
        .whiteUrl,
        .whiteCountry,
        .blackUrl,
        .blackCountry
    ]
}
