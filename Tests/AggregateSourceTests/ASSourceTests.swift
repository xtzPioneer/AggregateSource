import XCTest
import Combine
import CombineExt
@testable import AggregateSource

final class ASSourceTests: XCTestCase {
    
    var timeoutInterval: TimeInterval = 60 * 10
    
    var subscriptions = Set<AnyCancellable>()
    
    func testASSourceExample() throws {
        
        let networkExpectation = expectation(description: #function)
        
        let source = ASSource()
        
        let a = source.publisherLocationSearchResult("山阳")
        let b = source.publisherWeather(.init())
        let c = source.publisherHistoryToday()
        let d = source.publisherSolarTerms(Date().year)
        
        let e = source.publisherWWCHistoryToday()
        let f = source.publisherWWCHistory(.init())
        let g = source.publisherHolidays(Date().year)
        let h = source.publisherAdministrativeRegion()
        let j = source.publisherAlmanac(.init())
        
        let abcd = d.zip(a, b, c)
        let efgh = h.zip(e, f, g)
        let jklm = j
        
        abcd.zip(efgh, jklm).sink { completion in
            switch completion {
            case .finished:
                print("finished")
            case .failure(let error):
                print("error: \(error)")
            }
            networkExpectation.fulfill()
        } receiveValue: { data in
            print(data)
        }.store(in: &subscriptions)
        
        XCTWaiter(delegate: self).wait(for: [networkExpectation], timeout: timeoutInterval)
        
    }
    
}
