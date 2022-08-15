import Foundation
import Combine
import CombineExt

extension CZDHistoryTodayDataSource {
    
    /// 发布历史
    /// - Parameter date: 时间
    /// - Returns: 发布者
    public func publisherHistory(_ date: Date) -> PassthroughSubject<[CZDHistoryToday.CZDHistoryEvent], ASError> {
        let passthroughSubject = PassthroughSubject<[CZDHistoryToday.CZDHistoryEvent], ASError>()
        getHistory(date: date) { passthroughSubject.publisherResult($0) }
        return passthroughSubject
    }
    
    /// 发布历史上的今天
    /// - Returns: 发布者
    public func publisherHistoryToday() -> PassthroughSubject<[CZDHistoryToday.CZDHistoryEvent], ASError> {
        publisherHistory(.init())
    }
    
}
