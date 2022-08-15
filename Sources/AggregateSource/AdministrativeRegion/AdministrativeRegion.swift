import Foundation

/// 行政区域数据源(数据源来自于：https://github.com/modood/Administrative-divisions-of-China)
public protocol AdministrativeRegionDataSource {
    
    /// 获取行政区域(四级联动数据)
    func getAdministrativeRegion(completionHandler: @escaping (_ result: Result<[AdministrativeRegion.ARData], ASError>) -> Void)
    
}

/// 行政区域
public final class AdministrativeRegion: AdministrativeRegionDataSource {
    
    /// 行政区域数据省级(省份、直辖市、自治区)
    public struct ARData: Codable, Equatable {
        
        /// 代码
        public let code: String
        
        /// 名称
        public let name: String
        
        /// 地级(城市)
        public let children: [ChildrenData]
        
        /// 地级子数据(城市)
        public struct ChildrenData: Codable, Equatable {
            
            /// 代码
            public let code: String
            
            /// 名称
            public let name: String
            
            /// 县级(区县)
            public let children: [ChildrenData]
            
            /// 县级子数据(区县)
            public struct ChildrenData: Codable, Equatable {
                
                /// 代码
                public let code: String
                
                /// 名称
                public let name: String
                
                /// 乡级(乡镇、街道)
                public let children: [ChildrenData]
                
                /// 乡级子数据(乡镇、街道)
                public struct ChildrenData: Codable, Equatable {
                    
                    /// 代码
                    public let code: String
                    
                    /// 名称
                    public let name: String
                    
                }
                
            }
            
        }
        
    }
    
    public func getAdministrativeRegion(completionHandler: @escaping (_ result: Result<[ARData], ASError>) -> Void) {
        let url = Bundle.module.url(forResource: "pcas-code", withExtension: "json")
        guard let url = url else {
            completionHandler(.failure(.dataFault(.noneData)))
            return
        }
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let ars = try JSONDecoder().decode([AdministrativeRegion.ARData].self, from: data)
                DispatchQueue.main.async { completionHandler(.success(ars)) }
            } catch {
                DispatchQueue.main.async { completionHandler(.failure(.decodeFault)) }
            }
        }
    }
    
    /// 初始化行政区域
    public init() {}
    
}
