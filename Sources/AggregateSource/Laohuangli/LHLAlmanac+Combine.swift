import Foundation
import Combine
import CombineExt

extension LHLAlmanacDataSource {
    
    /// 发布老黄历年鉴
    /// - Parameter date: 时间
    /// - Returns: 发布者
    public func publisherAlmanac(_ date: Date) -> PassthroughSubject<LHLAlmanac.LHLData, ASError> {
        let passthroughSubject = PassthroughSubject<LHLAlmanac.LHLData, ASError>()
        getAlmanac(date: date) { passthroughSubject.publisherResult($0) }
        return passthroughSubject
    }
    
}
