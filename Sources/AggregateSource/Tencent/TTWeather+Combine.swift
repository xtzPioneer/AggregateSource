import Foundation
import Combine
import CombineExt

extension TTWeatherLocationSearch {
    
    /// 发布位置搜索结果
    /// - Parameter text: 市、区、县
    /// - Returns: 发布这
    public func publisherLocationSearchResult(_ text: String) -> PassthroughSubject<[TTLocation], ASError> {
        let passthroughSubject = PassthroughSubject<[TTLocation], ASError>()
        search(text, completionHandler: { passthroughSubject.publisherResult($0) })
        return passthroughSubject
    }
    
}

extension TTWeatherDataSource {
    
    /// 发布天气
    /// - Parameter location: 位置
    /// - Returns: 发布者
    public func publisherWeather(_ location: TTLocation) -> PassthroughSubject<TTWeather.WeatherData, ASError> {
        let passthroughSubject = PassthroughSubject<TTWeather.WeatherData, ASError>()
        getWeather(location, completionHandler: { passthroughSubject.publisherResult($0) })
        return passthroughSubject
    }
    
}
