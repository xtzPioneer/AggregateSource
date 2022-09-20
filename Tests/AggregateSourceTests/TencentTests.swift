import XCTest
import Combine
import CombineExt
@testable import AggregateSource

final class TencentTests: XCTestCase {
    
    var timeoutInterval: TimeInterval = 20
    
    var subscriptions = Set<AnyCancellable>()
    
    func testWeatherLocationExample() throws {
        
        let networkExpectation1 = expectation(description: "\(#function)1")
        let networkExpectation2 = expectation(description: "\(#function)2")
        let networkExpectation3 = expectation(description: "\(#function)3")
        
        let weatherLocation = TTWeatherLocation()
        
        weatherLocation.search("山阳县") { result in
            switch result {
            case .success(let data):
                print("data.count:\(data.count)")
                print("data:\(data)")
            case .failure(let error):
                print("error:\(error)")
            }
            networkExpectation1.fulfill()
        }
        
        weatherLocation.search("拱墅区") { result in
            switch result {
            case .success(let data):
                print("data.count:\(data.count)")
                print("data:\(data)")
            case .failure(let error):
                print("error:\(error)")
            }
            networkExpectation2.fulfill()
        }
        
        weatherLocation.search("杭州") { result in
            switch result {
            case .success(let data):
                print("data.count:\(data.count)")
                print("data:\(data)")
            case .failure(let error):
                print("error:\(error)")
            }
            networkExpectation3.fulfill()
        }
        
        XCTWaiter(delegate: self).wait(for: [networkExpectation1, networkExpectation2, networkExpectation3], timeout: timeoutInterval)
        
    }
    
    func testTTWeatherExample() throws {
        
        let networkExpectation = expectation(description: #function)
        
        let weather = TTWeather()
        
        weather.getWeather(.init()) { result in
            switch result {
            case .success(let data):
                print("weatherImageUrl:\(TTWeather.weatherImageUrl(data.observe.weather_code))")
                print("data:\(data)")
            case .failure(let error):
                print("error:\(error)")
            }
            networkExpectation.fulfill()
        }
        
        XCTWaiter(delegate: self).wait(for: [networkExpectation], timeout: timeoutInterval)
        
    }
    
    func testWeatherLocationCombineExample() throws {
        
        let networkExpectation = expectation(description: #function)
        
        let weatherLocation = TTWeatherLocation()
        weatherLocation.publisherLocationSearchResult("山阳").sink { completion in
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
    
    func testWeatherCombineExample() throws {
        
        let networkExpectation = expectation(description: #function)
        
        let weatherLocation = TTWeather()
        weatherLocation.publisherWeather(.init()).sink { completion in
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
