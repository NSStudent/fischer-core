import Foundation

public struct Bitboard: Equatable, Hashable {

    private(set) var rawValue: UInt64 = 0

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    public init() {}

    public struct Iterator: IteratorProtocol {

        fileprivate var bitboard: Bitboard

        public mutating func next() -> Square? {
            return bitboard.popLSBSquare()
        }
    }
}

extension Bitboard {
    public static func << (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let shifted = lhs.rawValue << rhs.rawValue
        return Bitboard(rawValue: shifted)
    }

    public static func >> (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let shifted = lhs.rawValue >> rhs.rawValue
        return Bitboard(rawValue: shifted)
    }

    public static func <<= (lhs: inout Bitboard, rhs: Bitboard) {
        lhs = lhs << rhs
    }

    public static func >>= (lhs: inout Bitboard, rhs: Bitboard) {
        lhs = lhs >> rhs
    }

    public static func & (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let ANDed = lhs.rawValue & rhs.rawValue
        return Bitboard(rawValue: ANDed)
    }

    public static func | (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let ORed = lhs.rawValue | rhs.rawValue
        return Bitboard(rawValue: ORed)
    }

    public static func ^ (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        let XORed = lhs.rawValue ^ rhs.rawValue
        return Bitboard(rawValue: XORed)
    }

    public static func > (lhs: Bitboard, rhs: Bitboard) -> Bool {
        lhs.rawValue > rhs.rawValue
    }

    public static func < (lhs: Bitboard, rhs: Bitboard) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static prefix func ~ (board: Bitboard) -> Bitboard {
        let inverted = ~board.rawValue
        return Bitboard(rawValue: inverted)
    }
}

extension Bitboard: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt64) {
        self.init(rawValue: value)
    }
}

extension Bitboard: Sequence {

    public var underestimatedCount: Int {
        return count
    }

    public func contains(_ element: Square) -> Bool {
        return self[element]
    }

    public func makeIterator() -> Iterator {
        return Iterator(bitboard: self)
    }
}

extension Bitboard {

    /// A lookup table of least significant bit indices.
    private static let lsbTable: [Int] = [00, 01, 48, 02, 57, 49, 28, 03,
                                          61, 58, 50, 42, 38, 29, 17, 04,
                                          62, 55, 59, 36, 53, 51, 43, 22,
                                          45, 39, 33, 30, 24, 18, 12, 05,
                                          63, 47, 56, 27, 60, 41, 37, 16,
                                          54, 35, 52, 21, 44, 32, 23, 11,
                                          46, 26, 40, 15, 34, 20, 31, 10,
                                          25, 14, 19, 09, 13, 08, 07, 06]

    /// A lookup table of most significant bit indices.
    private static let msbTable: [Int] = [00, 47, 01, 56, 48, 27, 02, 60,
                                          57, 49, 41, 37, 28, 16, 03, 61,
                                          54, 58, 35, 52, 50, 42, 21, 44,
                                          38, 32, 29, 23, 17, 11, 04, 62,
                                          46, 55, 26, 59, 40, 36, 15, 53,
                                          34, 51, 20, 43, 31, 22, 10, 45,
                                          25, 39, 14, 33, 19, 30, 09, 24,
                                          13, 18, 08, 12, 07, 06, 05, 63]

    /// A lookup table of bitboards for all squares.
    private static let bitboardTable: [Bitboard] = (0 ..< 64).map { Bitboard(rawValue: 1 << $0) }

    /// The De Bruijn multiplier.
    private static let debruijn64: UInt64 = 0x03f79d71b4cb0a89

    /// Returns the index of the lsb value.
    private func index(lsb value: Bitboard) -> Int? {
        guard value != 0 else {
            return nil
        }
        return Bitboard.lsbTable[Int((value.rawValue &* Bitboard.debruijn64) >> 58)]
    }

    /// The least significant bit.
    public var lsb: Bitboard {
        return Bitboard(rawValue: rawValue & (0 &- rawValue))
    }

    /// The index for the least significant bit of `self`.
    public var lsbIndex: Int? {
        return index(lsb: lsb)
    }

    /// The square for the least significant bit of `self`.
    public var lsbSquare: Square? {
        return lsbIndex.flatMap({ Square(rawValue: $0) })
    }

    private var msbShifted: UInt64 {
        var x = rawValue
        x |= x >> 1
        x |= x >> 2
        x |= x >> 4
        x |= x >> 8
        x |= x >> 16
        x |= x >> 32
        return x
    }

    /// The most significant bit.
    public var msb: Bitboard {
        return Bitboard(rawValue: (msbShifted >> 1) + 1)
    }

    /// The index for the most significant bit of `self`.
    public var msbIndex: Int? {
        guard rawValue != 0 else {
            return nil
        }
        return Bitboard.msbTable[Int((msbShifted &* Bitboard.debruijn64) >> 58)]
    }

    /// The square for the most significant bit of `self`.
    public var msbSquare: Square? {
        return msbIndex.flatMap({ Square(rawValue: $0) })
    }

    /// Removes the least significant bit and returns it.
    public mutating func popLSB() -> Bitboard {
        let lsb = self.lsb
        rawValue -= lsb.rawValue
        return lsb
    }

    /// Removes the least significant bit and returns its index, if any.
    public mutating func popLSBIndex() -> Int? {
        return index(lsb: popLSB())
    }

    /// Removes the least significant bit and returns its square, if any.
    public mutating func popLSBSquare() -> Square? {
        return popLSBIndex().flatMap({ Square(rawValue: $0) })
    }

    /// The number of bits set in `self`.
    public var count: Int {
        var n = rawValue
        n -= ((n >> 1) & 0x5555555555555555)
        n = (n & 0x3333333333333333) + ((n >> 2) & 0x3333333333333333)
        return Int((((n + (n >> 4)) & 0xF0F0F0F0F0F0F0F) &* 0x101010101010101) >> 56)
    }

    /// `true` if `self` is empty.
    public var isEmpty: Bool {
        return self == 0
    }

    /// `self` has more than one bit set.
    public var hasMoreThanOne: Bool {
        return rawValue & (rawValue &- 1) != 0
    }

    /// Returns `true` if `self` intersects `other`.
    public func intersects(_ other: Bitboard) -> Bool {
        return rawValue & other.rawValue != 0
    }

    /// Create a bitboard mask for `square`.
    ///
    /// - complexity: O(1).
    public init(square: Square) {
        self = Bitboard.bitboardTable[square.rawValue]
    }

    public init(location: Location) {
        let square = Square(location: location)
        self = .init(square: square)
    }

    /// Create a starting bitboard for `piece`.
    public init(startFor piece: Piece) {
        let value: Bitboard
        switch piece.kind {
        case .pawn:   value = 0xFF00
        case .knight: value = 0x0042
        case .bishop: value = 0x0024
        case .rook:   value = 0x0081
        case .queen:  value = 0x0008
        case .king:   value = 0x0010
        }
        self = piece.color.isWhite() ? value : value << (piece.kind.isPawn ? 40 : 56)
    }

    /// Create a bitboard from `squares`.
    public init<S: Sequence>(squares: S) where S.Iterator.Element == Square {
        rawValue = squares.reduce(0) { $0 | (1 << UInt64($1.rawValue)) }
    }

    /// Create a bitboard from `locations`.
    public init<S: Sequence>(locations: S) where S.Iterator.Element == Location {
        self.init(squares: locations.map(Square.init(location:)))
    }

    /// Create a bitboard from the start and end of `move`.
    public init(move: Move) {
        self.init(squares: [move.start, move.end])
    }

    /// Create a bitboard mask for `file`.
    public init(file: File) {
        switch file {
        case .a: rawValue = 0x0101010101010101
        case .b: rawValue = 0x0202020202020202
        case .c: rawValue = 0x0404040404040404
        case .d: rawValue = 0x0808080808080808
        case .e: rawValue = 0x1010101010101010
        case .f: rawValue = 0x2020202020202020
        case .g: rawValue = 0x4040404040404040
        case .h: rawValue = 0x8080808080808080
        }
    }

    /// Create a bitboard mask for `rank`.
    public init(rank: Rank) {
        rawValue = 0xFF << (UInt64(rank.index) * 8)
    }

    /// The `Bool` value for the bit at `square`.
    ///
    /// - complexity: O(1).
    public subscript(square: Square) -> Bool {
        get {
            return intersects(Bitboard.bitboardTable[square.rawValue])
        }
        set {
            let bit = Bitboard(square: square)
            if newValue {
                rawValue |= bit.rawValue
            } else {
                rawValue &= ~bit.rawValue
            }
        }
    }

    /// The `Bool` value for the bit at `location`.
    ///
    /// - complexity: O(1).
    public subscript(location: Location) -> Bool {
        get {
            return self[Square(location: location)]
        }
        set {
            self[Square(location: location)] = newValue
        }
    }

    public var ascii: String {
        let edge = "  +-----------------+\n"
        var result = edge
        let ranks = Rank.allCases.reversed()
        for rank in ranks {
            let strings = File.allCases.map({ file in self[(file, rank)] ? "1" : "." })
            let str = strings.joined(separator: " ")
            result += "\(rank.description) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h"
        return result
    }

}

extension Bitboard {
    /// Mask for bits not in File A.
    private static let notFileA: Bitboard = 0xfefefefefefefefe

    /// Mask for bits not in Files A and B.
    private static let notFileAB: Bitboard = 0xfcfcfcfcfcfcfcfc

    /// Mask for bits not in File H.
    private static let notFileH: Bitboard = 0x7f7f7f7f7f7f7f7f

    /// Mask for bits not in Files G and H.
    private static let notFileGH: Bitboard = 0x3f3f3f3f3f3f3f3f

    public static let allZeros: Bitboard = Bitboard(rawValue: 0)

    public static let edges: Bitboard = 0xff818181818181ff

    public enum ShiftDirection {
        case north
        case south
        case east
        case west
        case northeast
        case southeast
        case northwest
        case southwest
    }
}

extension Bitboard {
    /// Returns the pawn pushes available for `color` in `self`.
    internal func pawnPushes(for color: PlayerColor, empty: Bitboard) -> Bitboard {
        return (color.isWhite() ? shifted(toward: .north) : shifted(toward: .south)) & empty
    }

    /// Returns the attacks available to the pawns for `color` in `self`.
    internal func pawnAttacks(for color: PlayerColor) -> Bitboard {
        if color.isWhite() {
            return shifted(toward: .northeast) | shifted(toward: .northwest)
        } else {
            return shifted(toward: .southeast) | shifted(toward: .southwest)
        }
    }

    /// Returns the attacks available to the knight in `self`.
    internal func knightAttacks() -> Bitboard {
        let x = self
        let a = ((x << 17) | (x >> 15)) & Bitboard.notFileA
        let b = ((x << 10) | (x >> 06)) & Bitboard.notFileAB
        let c = ((x << 15) | (x >> 17)) & Bitboard.notFileH
        let d = ((x << 06) | (x >> 10)) & Bitboard.notFileGH
        return a | b | c | d
    }

    /// Returns the attacks available to the bishop in `self`.
    internal func bishopAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return filled(toward: .northeast, stoppers: bitboard).shifted(toward: .northeast)
            |  filled(toward: .northwest, stoppers: bitboard).shifted(toward: .northwest)
            |  filled(toward: .southeast, stoppers: bitboard).shifted(toward: .southeast)
            |  filled(toward: .southwest, stoppers: bitboard).shifted(toward: .southwest)
    }

    /// Returns the attacks available to the rook in `self`.
    internal func rookAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return filled(toward: .north, stoppers: bitboard).shifted(toward: .north)
            |  filled(toward: .south, stoppers: bitboard).shifted(toward: .south)
            |  filled(toward: .east, stoppers: bitboard).shifted(toward: .east)
            |  filled(toward: .west, stoppers: bitboard).shifted(toward: .west)
    }

    /// Returns the x-ray attacks available to the bishop in `self`.
    internal func xrayBishopAttacks(occupied occ: Bitboard, stoppers: Bitboard) -> Bitboard {
        let attacks = bishopAttacks(stoppers: occ)
        return attacks ^ bishopAttacks(stoppers: (stoppers & attacks) ^ stoppers)
    }

    /// Returns the x-ray attacks available to the rook in `self`.
    internal func xrayRookAttacks(occupied occ: Bitboard, stoppers: Bitboard) -> Bitboard {
        let attacks = rookAttacks(stoppers: occ)
        return attacks ^ rookAttacks(stoppers: (stoppers & attacks) ^ stoppers)
    }

    /// Returns the attacks available to the queen in `self`.
    internal func queenAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return rookAttacks(stoppers: bitboard) | bishopAttacks(stoppers: bitboard)
    }

    /// Returns the attacks available to the king in `self`.
    internal func kingAttacks() -> Bitboard {
        let attacks = shifted(toward: .east) | shifted(toward: .west)
        let bitboard = self | attacks
        return attacks
            | bitboard.shifted(toward: .north)
            | bitboard.shifted(toward: .south)
    }

    /// Returns the attacks available to `piece` in `self`.
    internal func attacks(for piece: Piece, stoppers: Bitboard = 0) -> Bitboard {
        switch piece.kind {
        case .pawn:
            return pawnAttacks(for: piece.color)
        case .knight:
            return knightAttacks()
        case .bishop:
            return bishopAttacks(stoppers: stoppers)
        case .rook:
            return rookAttacks(stoppers: stoppers)
        case .queen:
            return queenAttacks(stoppers: stoppers)
        case .king:
            return kingAttacks()
        }
    }

    /// Returns `self` flipped horizontally.
    public func flippedHorizontally() -> Bitboard {
        let x = 0x5555555555555555 as Bitboard
        let y = 0x3333333333333333 as Bitboard
        let z = 0x0F0F0F0F0F0F0F0F as Bitboard
        var n = self
        n = ((n >> 1) & x) | ((n & x) << 1)
        n = ((n >> 2) & y) | ((n & y) << 2)
        n = ((n >> 4) & z) | ((n & z) << 4)
        return n
    }

    /// Returns `self` flipped vertically.
    public func flippedVertically() -> Bitboard {
        let x = 0x00FF00FF00FF00FF as Bitboard
        let y = 0x0000FFFF0000FFFF as Bitboard
        var n = self
        n = ((n >>  8) & x) | ((n & x) <<  8)
        n = ((n >> 16) & y) | ((n & y) << 16)
        n =  (n >> 32)      |       (n << 32)
        return n
    }

    /// Returns the bits of `self` filled toward `direction` stopped by `stoppers`.
    public func filled(toward direction: ShiftDirection, stoppers: Bitboard) -> Bitboard {
        let empty = ~stoppers
        var bitboard = self
        for _ in 0 ..< 7 {
            bitboard.rawValue |= (empty.rawValue & bitboard.shifted(toward: direction).rawValue)
        }
        return bitboard
    }

    /// Returns the bits of `self` shifted once toward `direction`.
    public func shifted(toward direction: ShiftDirection) -> Bitboard {
        switch direction {
        case .north:     return  self << 8
        case .south:     return  self >> 8
        case .east:      return (self << 1) & Bitboard.notFileA
        case .northeast: return (self << 9) & Bitboard.notFileA
        case .southeast: return (self >> 7) & Bitboard.notFileA
        case .west:      return (self >> 1) & Bitboard.notFileH
        case .southwest: return (self >> 9) & Bitboard.notFileH
        case .northwest: return (self << 7) & Bitboard.notFileH
        }
    }

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Shifts the bits of `self` once toward `direction`.
    public mutating func shift(toward direction: ShiftDirection) {
        self = shifted(toward: direction)
    }

    /// Fills the bits of `self` toward `direction` stopped by `stoppers`.
    public mutating func fill(toward direction: ShiftDirection, stoppers: Bitboard = 0) {
        self = filled(toward: direction, stoppers: stoppers)
    }

    /// Swaps the bits between the two squares.
    public mutating func swap(_ first: Square, _ second: Square) {
        (self[first], self[second]) = (self[second], self[first])
    }

    /// Removes the most significant bit and returns it.
    public mutating func popMSB() -> Bitboard {
        let msb = self.msb
        rawValue -= msb.rawValue
        return msb
    }

    /// Removes the most significant bit and returns its index, if any.
    public mutating func popMSBIndex() -> Int? {
        guard rawValue != 0 else { return nil }
        let shifted = msbShifted
        rawValue -= (shifted >> 1) + 1
        return Bitboard.msbTable[Int((shifted &* Bitboard.debruijn64) >> 58)]
    }

    /// Removes the most significant bit and returns its square, if any.
    public mutating func popMSBSquare() -> Square? {
        return popMSBIndex().flatMap({ Square(rawValue: $0) })
    }

    /// Returns the ranks of `self` as eight 8-bit integers.
    public func ranks() -> [UInt8] {
        return (0 ..< 8).map { UInt8((rawValue >> ($0 * 8)) & 255) }
    }
}
