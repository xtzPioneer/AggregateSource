import XCTest
import Combine
import CombineExt
@testable import AggregateSource

final class TTChaTests: XCTestCase {
    
    var timeoutInterval: TimeInterval = 20
    
    var subscriptions = Set<AnyCancellable>()
    
    func testExample() throws {
        
        let networkExpectation = expectation(description: #function)
        
        let solarTerms = TTCSolarTerms()
        solarTerms.getSolarTerms(year: 2022) { result in
            switch result {
            case .success(let data):
                print("data.count:\(data.count)")
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
        
        let solarTerms = TTCSolarTerms()
        
        solarTerms.publisherSolarTerms(Date().year).sink { completion in
            switch completion {
            case .finished:
                print("finished")
            case .failure(let error):
                print("error: \(error)")
            }
            networkExpectation.fulfill()
        } receiveValue: { data in
            print("data.count:\(data.count)")
            print("data:\(data)")
        }.store(in: &subscriptions)
        
        XCTWaiter(delegate: self).wait(for: [networkExpectation], timeout: timeoutInterval)
        
    }
    
}
