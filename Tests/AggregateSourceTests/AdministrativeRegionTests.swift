import XCTest
import Combine
import CombineExt
@testable import AggregateSource

final class AdministrativeRegionTests: XCTestCase {
    
    var timeoutInterval: TimeInterval = 20
    
    var subscriptions = Set<AnyCancellable>()
    
    func testExample() throws {
        let networkExpectation = expectation(description: #function)
        
        AdministrativeRegion().getAdministrativeRegion { result in
            switch result {
            case .success(let data):
                data.forEach { data in
                    print("省份、直辖市、自治区:\(data.name)")
                    data.children.forEach { data in
                        print("地级(城市):\(data.name)")
                        data.children.forEach { data in
                            print("县级(区县):\(data.name)")
                            data.children.forEach { data in
                                print("乡级(乡镇、街道):\(data.name)")
                            }
                        }
                    }
                }
            case .failure(let error):
                print("error:\(error)")
            }
            networkExpectation.fulfill()
        }
        
        XCTWaiter(delegate: self).wait(for: [networkExpectation], timeout: timeoutInterval)
        
    }
    
}
