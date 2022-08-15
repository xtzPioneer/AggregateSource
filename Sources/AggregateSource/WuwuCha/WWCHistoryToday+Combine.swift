import Foundation
import Combine
import CombineExt

extension WWCHistoryTodayDataSource {
    
    /// 发布历史
    /// - Parameter date: 时间
    /// - Returns: 发布者
    public func publisherWWCHistory(_ date: Date) -> PassthroughSubject<[WWCHistoryToday.HistoryEvent], ASError> {
        let passthroughSubject = PassthroughSubject<[WWCHistoryToday.HistoryEvent], ASError>()
        getHistory(date: date) { passthroughSubject.publisherResult($0) }
        return passthroughSubject
    }
    
    /// 发布历史上的今天
    /// - Returns: 发布者
    public func publisherWWCHistoryToday() -> PassthroughSubject<[WWCHistoryToday.HistoryEvent], ASError> {
        publisherWWCHistory(.init())
    }
    
}
