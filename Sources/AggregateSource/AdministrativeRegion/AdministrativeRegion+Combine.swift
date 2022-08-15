import Foundation
import Combine
import CombineExt

extension AdministrativeRegionDataSource {
    
    /// 发布行政区域(四级联动数据)
    /// - Returns: 发布者
    public func publisherAdministrativeRegion() -> PassthroughSubject<[AdministrativeRegion.ARData], ASError> {
        let passthroughSubject = PassthroughSubject<[AdministrativeRegion.ARData], ASError>()
        getAdministrativeRegion { passthroughSubject.publisherResult($0) }
        return passthroughSubject
    }
    
}
