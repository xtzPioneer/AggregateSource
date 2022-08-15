import Foundation
import Combine
import CombineExt

extension BDHolidaysDataSource {
    
    /// 发布节假日
    /// - Parameter year: 年
    /// - Returns: 发布者
    public func publisherHolidays(_ year: Int) -> PassthroughSubject<[BDHolidays.HolidaysData.Almanac], ASError> {
        let passthroughSubject = PassthroughSubject<[BDHolidays.HolidaysData.Almanac], ASError>()
        getHolidays(year: year) { passthroughSubject.publisherResult($0) }
        return passthroughSubject
    }
    
}
