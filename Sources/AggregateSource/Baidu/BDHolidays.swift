import Foundation
import Alamofire

/// 节假日数据源
public protocol BDHolidaysDataSource {
    
    /// 获取节假日
    /// - Parameters:
    ///   - year: 年
    ///   - completionHandler: 完成处理
    func getHolidays(year: Int, completionHandler: @escaping (Result<[BDHolidays.HolidaysData.Almanac], ASError>) -> Void)
    
}

/// 节假日
public final class BDHolidays: ASTimeoutInterval, BDHolidaysDataSource {
    
    /// 节假日结果
    struct HolidaysResult: Codable, Equatable {
        
        /// 状态
        let state: String
        
        /// 时间戳
        let time: String
        
        /// 设置缓存时间
        let set_cache_time: String
        
        /// 数据
        let data: [HolidaysData]
        
        /// 编码Keys
        private enum CodingKeys: String, CodingKey {
            case state = "status"
            case time = "t"
            case set_cache_time
            case data
        }
        
        /// 初始化节假日结果
        /// - Parameter decoder: 译码器
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state = try container.decode(String.self, forKey: .state)
            time = try container.decode(String.self, forKey: .time)
            set_cache_time = try container.decode(String.self, forKey: .set_cache_time)
            data = try container.decode([HolidaysData].self, forKey: .data)
        }
        
    }
    
    /// 节假日数据
    public struct HolidaysData: Codable, Equatable {
        
        /// 扩展位置
        public let extendedLocation: String
        
        /// 原始查询
        public let originQuery: String
        
        /// 网站ID
        public let siteId: Int
        
        /// 标准STG
        public let stdStg: Int
        
        /// 标准STL
        public let stdStl: Int
        
        /// 选择时间
        public let select_time: TimeInterval
        
        /// 更新时间
        public let update_time: String
        
        /// 版本
        public let version: Int
        
        /// 年鉴
        public let almanac: [Almanac]
        
        /// App信息
        public let appinfo: String
        
        /// AppID
        public let cambrian_appid: String
        
        /// 类型
        public let disp_type: Int
        
        /// Fetchkey
        public let fetchkey: String
        
        /// key
        public let key: String
        
        /// Loc
        public let loc: String
        
        /// 资源ID
        public let resourceid: String
        
        /// 角色ID
        public let role_id: Int
        
        /// 指示灯
        public let showlamp: String
        
        /// Tplt
        public let tplt: String
        
        /// Url
        public let url: String
        
        /// 编码Keys
        private enum CodingKeys: String, CodingKey {
            case extendedLocation = "ExtendedLocation"
            case originQuery = "OriginQuery"
            case siteId = "SiteId"
            case stdStg = "StdStg"
            case stdStl = "StdStl"
            case select_time = "_select_time"
            case update_time = "_update_time"
            case version = "_version"
            case almanac
            case appinfo
            case cambrian_appid
            case disp_type
            case fetchkey
            case key
            case loc
            case resourceid
            case role_id
            case showlamp
            case tplt
            case url
        }
        
        /// 初始化节假日数据
        /// - Parameter decoder: 译码器
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            extendedLocation = try container.decode(String.self, forKey: .extendedLocation)
            originQuery = try container.decode(String.self, forKey: .originQuery)
            siteId = try container.decode(Int.self, forKey: .siteId)
            stdStg = try container.decode(Int.self, forKey: .stdStg)
            stdStl = try container.decode(Int.self, forKey: .stdStl)
            select_time = try container.decode(TimeInterval.self, forKey: .select_time)
            update_time = try container.decode(String.self, forKey: .update_time)
            version = try container.decode(Int.self, forKey: .version)
            appinfo = try container.decode(String.self, forKey: .appinfo)
            cambrian_appid = try container.decode(String.self, forKey: .cambrian_appid)
            disp_type = try container.decode(Int.self, forKey: .disp_type)
            fetchkey = try container.decode(String.self, forKey: .fetchkey)
            key = try container.decode(String.self, forKey: .key)
            loc = try container.decode(String.self, forKey: .loc)
            resourceid = try container.decode(String.self, forKey: .resourceid)
            role_id = try container.decode(Int.self, forKey: .role_id)
            showlamp = try container.decode(String.self, forKey: .showlamp)
            tplt = try container.decode(String.self, forKey: .tplt)
            url = try container.decode(String.self, forKey: .url)
            almanac = try container.decode([Almanac].self, forKey: .almanac)
        }
        
        /// 年鉴
        public struct Almanac: Codable, Equatable {
            
            /// 生肖(如：牛)
            public let animal: String
            
            /// 避免(如：结婚.搬家.搬新房.祈福.盖屋.祭祀.作灶.探病.掘井.谢土)
            public let avoid: String
            
            /// 时间日期(如：六)
            public let cnDay: String
            
            /// 黄历日(如：甲寅)
            public let gzDate: String
            
            /// 黄历月(如：庚子)
            public let gzMonth: String
            
            /// 黄历年(如：辛丑)
            public let gzYear: String
            
            /// 是否大月(如：1)
            public let isBigMonth: String
            
            /// 农历日(如：廿九)
            public let lDate: String
            
            /// 农历月(如：十一)
            public let lMonth: String
            
            /// 农历日(如：29)
            public let lunarDate: String
            
            /// 农历月(如：1)
            public let lunarMonth: String
            
            /// 农历年(如：2021)
            public let lunarYear: String
            
            /// 时间
            public let oDate: String
            
            /// 适合(如：打扫.理发.签订合同.交易.开业.栽种.安床.安葬.挂匾.修造.拆卸.开光)
            public let suit: String
            
            /// 阳历年(如：2022)
            public let year: String
            
            /// 阳历月(如：1)
            public let month: String
            
            /// 阳历日(如：1)
            public let day: String
            
            /// 格式
            public let yj_from: String
            
            /// 农历节日(如：小寒)
            public let term: String?
            
            /// 阳历节日(如：国际海关日)
            public let value: String?
            
            /// 状态(1：法定节假日 2：调休上班)
            public let status: String?
            
            /// 类型
            public let type: String?
            
            /// 描述(如：植树节)
            public let desc: String?
            
        }
        
    }
    
    /// 节假日Url
    /// - Parameter date: 时间
    /// - Returns: Url
    private func url(year: Int, month: Int) -> String {
        "https://sp1.baidu.com/8aQDcjqpAAV3otqbppnN2DJv/api.php?tn=wisetpl&format=json&resource_id=39043&query=\(year)%E5%B9%B4\(month)%E6%9C%88&t=\(Date().milliStamp)"
    }
    
    public var timeoutInterval: TimeInterval?
    
    /// 获取节假日
    /// - Parameters:
    ///   - url: Url
    ///   - completionHandler: 完成回调
    private func getHolidays(url: String, completionHandler: @escaping (_ result: Result<[BDHolidays.HolidaysData], ASError>) -> Void) {
        AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, requestModifier: timeoutIntervalRequestModifier(request:)).response {
            switch $0.result {
            case .success(let data):
                guard let data = data else {
                    completionHandler(.failure(ASError.dataFault(.noneData)))
                    return
                }
                let customEncoding = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                guard let result = String(data: data, encoding: String.Encoding(rawValue: customEncoding)) else {
                    completionHandler(.failure(ASError.encodingFault))
                    return
                }
                guard let result = result.data(using: .utf8) else {
                    completionHandler(.failure(ASError.encodingFault))
                    return
                }
                guard let holidaysResult = try? JSONDecoder().decode(HolidaysResult.self, from: result) else {
                    completionHandler(.failure(ASError.decodeFault))
                    return
                }
                completionHandler(.success(holidaysResult.data))
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    public func getHolidays(year: Int, completionHandler: @escaping (_ result: Result<[BDHolidays.HolidaysData.Almanac], ASError>) -> Void) {
        var success = [[BDHolidays.HolidaysData]]()
        var errors = [ASError]()
        let requests = [
            url(year: year, month: 2),
            url(year: year, month: 5),
            url(year: year, month: 8),
            url(year: year, month: 11),
        ]
        let resultHandler: (Result<[BDHolidays.HolidaysData], ASError>) -> Void = { result in
            switch result {
            case .success(let data):
                success.append(data)
            case .failure(let error):
                errors.append(error)
            }
            guard (success.count + errors.count) == requests.count else { return }
            if let error = errors.last {
                completionHandler(.failure(error))
            } else {
                let holidaysDatas = success.flatMap { $0 }.flatMap { $0.almanac }
                guard holidaysDatas.count > 0 else {
                    completionHandler(.failure(.dataFault(.noneData)))
                    return
                }
                completionHandler(.success(holidaysDatas))
            }
        }
        requests.forEach({ getHolidays(url: $0, completionHandler: resultHandler) })
    }
    
    /// 初始化节假日
    public init() {}
    
    /// 初始化节假日
    /// - Parameter timeoutInterval: 超时间隔
    public init(_ timeoutInterval: TimeInterval?) {
        self.timeoutInterval = timeoutInterval
    }
    
}

