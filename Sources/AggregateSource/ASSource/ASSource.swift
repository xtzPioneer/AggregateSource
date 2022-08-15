import Foundation
import Combine
import CombineExt

/// 源
public final class ASSource: ASTimeoutInterval {
    
    public var timeoutInterval: TimeInterval?
    
    /// 初始化源
    public init() {}
    
    /// 初始化源
    /// - Parameter timeoutInterval: 超时间隔
    public init(_ timeoutInterval: TimeInterval?) {
        self.timeoutInterval = timeoutInterval
    }
    
}

extension ASSource: BDHolidaysDataSource,
                    CZDHistoryTodayDataSource,
                    TTWeatherLocationSearch,
                    TTWeatherDataSource,
                    TTCSolarTermsDataSource,
                    WWCHistoryTodayDataSource,
                    AdministrativeRegionDataSource,
                    LHLAlmanacDataSource {
    
    public func getHolidays(year: Int, completionHandler: @escaping (_ result: Result<[BDHolidays.HolidaysData.Almanac], ASError>) -> Void) {
        BDHolidays(timeoutInterval).getHolidays(year: year, completionHandler: completionHandler)
    }
    
    public func getHistory(date: Date, completionHandler: @escaping (_ result: Result<[CZDHistoryToday.CZDHistoryEvent], ASError>) -> Void) {
        CZDHistoryToday(timeoutInterval).getHistory(date: date, completionHandler: completionHandler)
    }
    
    public func getHistoryToday(completionHandler: @escaping (_ result: Result<[CZDHistoryToday.CZDHistoryEvent], ASError>) -> Void) {
        CZDHistoryToday(timeoutInterval).getHistoryToday(completionHandler: completionHandler)
    }
    
    public func search(_ text: String, completionHandler: @escaping (_ result: Result<[TTLocation], ASError>) -> Void) {
        TTWeatherLocation(timeoutInterval).search(text, completionHandler: completionHandler)
    }
    
    public func getWeather(_ location: TTLocation, completionHandler: @escaping (_ result: Result<TTWeather.WeatherData, ASError>) -> Void) {
        TTWeather(timeoutInterval).getWeather(location, completionHandler: completionHandler)
    }
    
    public func getSolarTerms(year: Int, completionHandler: @escaping (_ result: Result<[TTCSolarTerms.SolarTermsData], ASError>) -> Void) {
        TTCSolarTerms(timeoutInterval).getSolarTerms(year: year, completionHandler: completionHandler)
    }
    
    public func getHistory(date: Date, completionHandler: @escaping (_ result: Result<[WWCHistoryToday.HistoryEvent], ASError>) -> Void) {
        WWCHistoryToday(timeoutInterval).getHistory(date: date, completionHandler: completionHandler)
    }
    
    public func getHistoryToday(completionHandler: @escaping (_ result: Result<[WWCHistoryToday.HistoryEvent], ASError>) -> Void) {
        WWCHistoryToday(timeoutInterval).getHistoryToday(completionHandler: completionHandler)
    }
    
    public func getAdministrativeRegion(completionHandler: @escaping (_ result: Result<[AdministrativeRegion.ARData], ASError>) -> Void) {
        AdministrativeRegion().getAdministrativeRegion(completionHandler: completionHandler)
    }
    
    public func getAlmanac(date: Date, completionHandler: @escaping (_ result: Result<LHLAlmanac.LHLData, ASError>) -> Void) {
        LHLAlmanac(timeoutInterval).getAlmanac(date: date, completionHandler: completionHandler)
    }
    
}
