import Foundation
import Alamofire

/// 搜索结果
struct TTResult<Data: Codable>: Codable {
    
    /// 数据
    let data: Data?
    
    /// 信息
    let message: String
    
    /// 状态
    let status: Int
    
}

/// 位置
public struct TTLocation: Codable, Equatable {
    
    /// 省(省份、直辖市、自治区)
    public let province: String
    
    /// 城市
    public let city: String
    
    /// 区县
    public let county: String?
    
    /// 初始化位置
    public init(
        province: String = "浙江省",
        city: String = "杭州市",
        county: String? = nil
    ) {
        self.province = province
        self.city = city
        self.county = county
    }
    
}

/// 天气位置搜索
public protocol TTWeatherLocationSearch {
    
    /// 搜索天气位置
    /// - Parameters:
    ///   - text: 市、区、县
    ///   - completionHandler: 完成处理
    func search(_ text: String, completionHandler: @escaping (Result<[TTLocation], ASError>) -> Void)
    
}

/// 天气位置
public final class TTWeatherLocation: ASTimeoutInterval, TTWeatherLocationSearch {
    
    public var timeoutInterval: TimeInterval?
    
    /// Url
    /// - Returns: Url
    private func url() -> String {
        "https://wis.qq.com/city/like"
    }
    
    public func search(_ text: String, completionHandler: @escaping (_ result: Result<[TTLocation], ASError>) -> Void) {
        let parameters = [
            "source": "pc",
            "city": text,
            "_": Date().milliStamp
        ]
        AF.request(url(), method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, requestModifier: timeoutIntervalRequestModifier(request:)).response {
            switch $0.result {
            case .success(let data):
                guard let data = data else {
                    completionHandler(.failure(ASError.dataFault(.noneData)))
                    return
                }
                guard let data = String(data: data, encoding: .utf8) else {
                    completionHandler(.failure(.encodingFault))
                    return
                }
                guard let data = data.data(using: .utf8) else {
                    completionHandler(.failure(.encodingFault))
                    return
                }
                do {
                    let searchResult = try JSONDecoder().decode(TTResult<[String: String]>.self, from: data)
                    guard searchResult.status == 200 else {
                        completionHandler(.failure(.analysisFault(.dataSourceError)))
                        return
                    }
                    guard let data = searchResult.data else {
                        completionHandler(.failure(.dataFault(.noneData)))
                        return
                    }
                    let locationTexts = data.values.map({ $0.components(separatedBy: ",") })
                    guard locationTexts.count != 0 else {
                        completionHandler(.failure(.dataFault(.noneData)))
                        return
                    }
                    let locations: [TTLocation] = locationTexts.map({
                        switch $0.count {
                        case 1:
                            return .init(province: $0[0])
                        case 2:
                            return .init(province: $0[0], city: $0[1])
                        case 3:
                            return .init(province: $0[0], city: $0[1], county: $0[2])
                        default:
                            return .init()
                        }
                    })
                    completionHandler(.success(locations))
                } catch let error {
                    completionHandler(.failure(.analysisFault(.otherFault(error))))
                }
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    /// 初始化天气位置
    public init() {}
    
    /// 初始化天气位置
    /// - Parameter timeoutInterval: 超时间隔
    public init(_ timeoutInterval: TimeInterval?) {
        self.timeoutInterval = timeoutInterval
    }
    
}

/// 天气数据源
public protocol TTWeatherDataSource {
    
    /// 获取天气
    /// - Parameters:
    ///   - location: 位置
    ///   - completionHandler: 完成处理
    func getWeather(_ location: TTLocation, completionHandler: @escaping (Result<TTWeather.WeatherData, ASError>) -> Void)
    
}

/// 天气
public final class TTWeather: ASTimeoutInterval, TTWeatherDataSource {
    
    public var timeoutInterval: TimeInterval?
    
    /// 天气数据
    public struct WeatherData: Codable, Equatable {
        
        /// 警报
        public let alarm: Alarm
        
        /// 逐小时预报(预测1小时)
        public let forecast_1hs: [Forecast1h]
        
        /// 7日天气预报(预测24小时)
        public let forecast_24hs: [Forecast24h]
        
        /// 生活指数
        public let index: Index
        
        /// 限行
        public let limit: Limit
        
        /// 观测
        public let observe: Observe
        
        /// 日出日落
        public let rise: [Rise]
        
        /// 提示
        public let tips: Tips
        
        /// 空气
        public let air: Air
        
        /// 编码Keys
        private enum CodingKeys: String, CodingKey {
            case alarm
            case forecast_1hs = "forecast_1h"
            case forecast_24hs = "forecast_24h"
            case index
            case limit
            case observe
            case rise
            case tips
            case air
        }
        
        /// 初始化天气数据
        /// - Parameter decoder: 译码器
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            alarm = try container.decode(Alarm.self, forKey: .alarm)
            forecast_1hs = try container.decode([String: Forecast1h].self, forKey: .forecast_1hs).map({ $0.value })
            forecast_24hs = try container.decode([String: Forecast24h].self, forKey: .forecast_24hs).map({ $0.value })
            air = try container.decode(Air.self, forKey: .air)
            index = try container.decode(Index.self, forKey: .index)
            limit = try container.decode(Limit.self, forKey: .limit)
            observe = try container.decode(Observe.self, forKey: .observe)
            rise = try container.decode([String: Rise].self, forKey: .rise).map({ $0.value })
            tips = try container.decode(Tips.self, forKey: .tips)
        }
        
        /// 警报
        public struct Alarm: Codable, Equatable {
            
        }
        
        /// 预测1小时
        public struct Forecast1h: Codable, Equatable {
            
            /// 温度
            public let degree: String
            
            /// 更新时间
            public let update_time: String
            
            /// 天气
            public let weather: String
            
            /// 天气代码
            public let weather_code: String
            
            /// 短期天气
            public let weather_short: String
            
            /// 风向
            public let wind_direction: String
            
            /// 风力
            public let wind_power: String
        }
        
        /// 预测24小时
        public struct Forecast24h: Codable, Equatable {
            
            /// 白天天气
            public let day_weather: String
            
            /// 白天天气代码
            public let day_weather_code: String
            
            /// 白天短期天气
            public let day_weather_short: String
            
            /// 白天风向
            public let day_wind_direction: String
            
            /// 白天风向代码
            public let day_wind_direction_code: String
            
            /// 白天风力
            public let day_wind_power: String
            
            /// 白天风力代码
            public let day_wind_power_code: String
            
            /// 最高温度
            public let max_degree: String
            
            /// 最低温度
            public let min_degree: String
            
            /// 晚上天气
            public let night_weather: String
            
            /// 晚上天气代码
            public let night_weather_code: String
            
            /// 晚上短期天气
            public let night_weather_short: String
            
            /// 晚上天气风向
            public let night_wind_direction: String
            
            /// 晚上天气风向代码
            public let night_wind_direction_code: String
            
            /// 晚上天气风力
            public let night_wind_power: String
            
            /// 晚上天气风力代码
            public let night_wind_power_code: String
            
            /// 时间
            public let time: String
            
        }
        
        /// 索引
        public struct Index: Codable, Equatable {
            
            /// 空调开启
            public let airconditioner: Content
            
            /// 过敏
            public let allergy: Content
            
            /// 洗车
            public let carwash: Content
            
            /// 风寒
            public let chill: Content
            
            /// 穿衣
            public let clothes: Content
            
            /// 感冒
            public let cold: Content
            
            /// 舒适度
            public let comfort: Content
            
            /// 空气污染扩散条件
            public let diffusion: Content
            
            /// 路况
            public let dry: Content
            
            /// 晾晒
            public let drying: Content
            
            /// 钓鱼
            public let fish: Content
            
            /// 中暑
            public let heatstroke: Content
            
            /// 化妆
            public let makeup: Content
            
            /// 心情
            public let mood: Content
            
            /// 晨练
            public let morning: Content
            
            /// 运动
            public let sports: Content
            
            /// 太阳镜
            public let sunglasses: Content
            
            /// 防晒
            public let sunscreen: Content
            
            /// 时间
            public let time: String
            
            /// 旅游
            public let tourism: Content
            
            /// 交通
            public let traffic: Content
            
            /// 紫外线强度
            public let ultraviolet: Content
            
            /// 雨伞
            public let umbrella: Content
            
            /// 内容
            public struct Content: Codable, Equatable {
                
                /// 详情
                public let detail: String
                
                /// 信息
                public let info: String
                
                /// 名称
                public let name: String
                
            }
            
        }
        
        /// 限行
        public struct Limit: Codable, Equatable {
            
            /// 车牌号
            public let tail_number: String
            
            /// 时间
            public let time: String
            
        }
        
        /// 观测
        public struct Observe: Codable, Equatable {
            
            /// 温度
            public let degree: String
            
            /// 湿度
            public let humidity: String
            
            /// 降水
            public let precipitation: String
            
            /// 压力
            public let pressure: String
            
            /// 更新时间
            public let update_time: String
            
            /// 天气
            public let weather: String
            
            /// 天气代码
            public let weather_code: String
            
            /// 短期天气
            public let weather_short: String
            
            /// 风向
            public let wind_direction: String
            
        }
        
        /// 日出日落
        public struct Rise: Codable, Equatable {
            
            /// 日出
            public let sunrise: String
            
            /// 日落
            public let sunset: String
            
            /// 时间
            public let time: String
            
        }
        
        /// 提示
        public struct Tips: Codable, Equatable {
            
            /// 观测
            public let observe: [String]
            
            /// 编码Keys
            private enum CodingKeys: String, CodingKey {
                case observe
            }
            
            /// 初始化提示
            /// - Parameter decoder: 译码器
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                observe = try container.decode([String: String].self, forKey: .observe).map({ $0.value })
            }
            
        }
        
        /// 空气
        public struct Air: Codable, Equatable {
            
            /// 空气指数
            public let aqi: Int
            
            /// 空气指数级别
            public let aqi_level: Int
            
            /// 空气指数名称
            public let aqi_name: String
            
            /// 空气CO(污染物)
            public let co: String
            
            /// 空气NO2(二氧化氮)
            public let no2: String
            
            /// 空气O3(臭氧)
            public let o3: String
            
            /// 空气PM10(颗粒物因粒径)
            public let pm10: String
            
            /// 空气PM2.5(颗粒物因粒径)
            public let pm2_5: String
            
            /// 空气SO2(二氧化硫)
            public let so2: String
            
            /// 更新时间
            public let update_time: String
            
            /// 编码Keys
            private enum CodingKeys: String, CodingKey {
                case aqi
                case aqi_level
                case aqi_name
                case co
                case no2
                case o3
                case pm10
                case pm2_5 = "pm2.5"
                case so2
                case update_time
            }
            
        }
        
    }
    
    /// Url
    /// - Returns: Url
    private func url() -> String {
        "https://wis.qq.com/weather/common"
    }
    
    public func getWeather(_ location: TTLocation, completionHandler: @escaping (_ result: Result<TTWeather.WeatherData, ASError>) -> Void) {
        let parameters = try? JSONDecoder().decode([String: String].self, from: JSONEncoder().encode(location))
        guard var parameters = parameters, !parameters.isEmpty else {
            completionHandler(.failure(.parametersFault(.noneParameters)))
            return
        }
        parameters["source"] = "pc"
        parameters["weather_type"] = "observe|forecast_1h|forecast_24h|index|alarm|limit|tips|rise|air"
        parameters["_"] = Date().milliStamp
        AF.request(url(), method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, requestModifier: timeoutIntervalRequestModifier(request:)).response {
            switch $0.result {
            case .success(let data):
                guard let data = data else {
                    completionHandler(.failure(ASError.dataFault(.noneData)))
                    return
                }
                guard let data = String(data: data, encoding: .utf8) else {
                    completionHandler(.failure(.encodingFault))
                    return
                }
                guard let data = data.data(using: .utf8) else {
                    completionHandler(.failure(.encodingFault))
                    return
                }
                do {
                    let weatherResult = try JSONDecoder().decode(TTResult<WeatherData>.self, from: data)
                    guard weatherResult.status == 200 else {
                        completionHandler(.failure(.analysisFault(.dataSourceError)))
                        return
                    }
                    guard let data = weatherResult.data else {
                        completionHandler(.failure(.dataFault(.noneData)))
                        return
                    }
                    completionHandler(.success(data))
                } catch let error {
                    completionHandler(.failure(.analysisFault(.otherFault(error))))
                }
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    /// 初始化天气
    public init() {}
    
    /// 初始化天气
    /// - Parameter timeoutInterval: 超时间隔
    public init(_ timeoutInterval: TimeInterval?) {
        self.timeoutInterval = timeoutInterval
    }
    
}
