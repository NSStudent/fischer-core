import Testing
@testable import FischerCore

final class RankTests {
    
    @Test("Rank all init")
    func testInit() throws {
        #expect(Rank(index: 0) == .one)
        #expect(Rank(rawValue: 1) == .one)
        #expect(Rank(1) == .one)
    }
    
    @Test("Rank Index")
    func testRankIndex() throws {
        #expect(Rank.one.index == 0)
    }
    
    @Test("Rank Opposite")
    func testOpposite() throws {
        #expect(Rank.one.opposite() == .eight)
    }
    
    @Test("Rank Description")
    func testDescription() throws {
        #expect(Rank.one.description == "1")
    }
    
    @Test("Rank Comparable")
    func testComparable() throws {
        #expect(Rank.one < .two)
        #expect(!(Rank.one > .two))
        #expect(!(Rank.one == .two))
        #expect(Rank.one == .one)
    }
    
    @Test("Rank Integer value")
    func testInteger() throws {
        let rank: Rank = 1
        #expect(rank == .one)
    }
    
    @Test("Rank Start and End")
    func testStartAndEndRanks() throws {
        #expect(Rank.init(startFor: .white) == 1)
        #expect(Rank.init(startFor: .black) == 8)
        
        #expect(Rank.init(endFor: .white) == 8)
        #expect(Rank.init(endFor: .black) == 1)
    }
}
