import XCTest
import Combine
import CombineExt
import SwiftDate
@testable import AggregateSource

final class LaohuangliTests: XCTestCase {
    
    var timeoutInterval: TimeInterval = 20
    
    var subscriptions = Set<AnyCancellable>()
    
    func testExample() throws {
        
        let networkExpectation = expectation(description: #function)
        
        let almanac = LHLAlmanac()
        almanac.getAlmanac(date: Date()) { result in
            switch result {
            case .success(let data):
                print("data:\(data)")
            case .failure(let error):
                print("error:\(error)")
            }
            networkExpectation.fulfill()
        }
        XCTWaiter(delegate: self).wait(for: [networkExpectation], timeout: timeoutInterval)
        
    }
    
    func testCombineExample() throws {
        
        let networkExpectation = expectation(description: #function)
        
        let almanac = LHLAlmanac()
        almanac.publisherAlmanac(Date()).sink { completion in
            switch completion {
            case .finished:
                print("finished")
            case .failure(let error):
                print("error: \(error)")
            }
            networkExpectation.fulfill()
        } receiveValue: { data in
            print("data:\(data)")
        }.store(in: &subscriptions)
        
        XCTWaiter(delegate: self).wait(for: [networkExpectation], timeout: timeoutInterval)
        
    }
    
}
