import Foundation

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

final class SimpleRandom {
    static func random(_ range: ClosedRange<Int32>) -> Int32 {
        guard range.lowerBound != range.upperBound else { return range.lowerBound }
        
        #if os(Linux)
        precondition(randomInitialized)
        var r: Int32
        let n = range.upperBound - range.lowerBound
        repeat { r = rand() } while (r >= RAND_MAX - RAND_MAX % n)
        return r % n + range.lowerBound
        #else
        let n = UInt32(range.upperBound - range.lowerBound)
        let r = arc4random_uniform(n)
        return Int32(r) + range.lowerBound
        #endif
    }
}

#if os(Linux)
private let randomInitialized: Bool = {
    let current = Date().timeIntervalSinceReferenceDate
    let salt = current.truncatingRemainder(dividingBy: 1) * 100000000
    srand(UInt32(current + salt))
    return true
}()
#endif

