import Foundation
import Combine
import CombineExt

extension TTCSolarTermsDataSource {
    
    /// 发布节气
    /// - Parameter year: 年
    /// - Returns: 发布者
    public func publisherSolarTerms(_ year: Int) -> PassthroughSubject<[TTCSolarTerms.SolarTermsData], ASError> {
        let passthroughSubject = PassthroughSubject<[TTCSolarTerms.SolarTermsData], ASError>()
        getSolarTerms(year: year) { passthroughSubject.publisherResult($0) } 
        return passthroughSubject
    }
    
}

