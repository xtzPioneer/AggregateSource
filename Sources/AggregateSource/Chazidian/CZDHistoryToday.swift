import Foundation
import Alamofire
import Kanna

/// 历史上的今天数据源
public protocol CZDHistoryTodayDataSource {
    
    /// 获取历史
    /// - Parameters:
    ///   - date: 时间
    ///   - completionHandler: 完成处理
    func getHistory(date: Date, completionHandler: @escaping (Result<[CZDHistoryToday.CZDHistoryEvent], ASError>) -> Void)
    
    /// 获取历史上的今天
    /// - Parameter completionHandler: 完成处理
    func getHistoryToday(completionHandler: @escaping (Result<[CZDHistoryToday.CZDHistoryEvent], ASError>) -> Void)
    
}

/// 历史上的今天
public final class CZDHistoryToday: ASTimeoutInterval, CZDHistoryTodayDataSource {
    
    public var timeoutInterval: TimeInterval?
    
    /// 历史事件
    public struct CZDHistoryEvent: Codable, Equatable {
        
        /// 年
        public let year: Event
        
        /// 月日
        public let monthDay: Event
        
        /// 内容
        public let content: Event
        
        /// 事件
        public struct Event: Codable, Equatable {
            
            /// 标题
            public let title: String
            
            /// 链接
            public let link: String
            
        }
        
    }
    
    /// 历史上的今天Url
    /// - Parameter date: 时间
    /// - Returns: Url
    private func url(_ date: Date) -> String {
        let url = "https://www.chazidian.com/d/\(date.month)-\(date.day)/"
        return url
    }
    
    public func getHistory(date: Date, completionHandler: @escaping (_ result: Result<[CZDHistoryEvent], ASError>) -> Void) {
        AF.request(url(date), method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, requestModifier: timeoutIntervalRequestModifier(request:)).response {
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
                do {
                    let htmlDocument = try HTML(html: data, encoding: .utf8)
                    guard let analysisResult = htmlDocument.xpath("//div[@class='histday_cont']").first?.xpath("/ul/li") else {
                        completionHandler(.failure(ASError.analysisFault(.formatError)))
                        return
                    }
                    var historyTodays = [CZDHistoryToday.CZDHistoryEvent]()
                    analysisResult.forEach {
                        let titles = $0.xpath("/a").map({ $0.text ?? "" })
                        let links = $0.xpath("/a/@href").map({ $0.text ?? ""})
                        guard titles.count >= 3, links.count >= 3 else { return }
                        let yearTitle: String = titles[0].replacingOccurrences(of: "【", with: "").replacingOccurrences(of: "】", with: "")
                        let year: CZDHistoryToday.CZDHistoryEvent.Event = .init(title: yearTitle, link: links[0])
                        let monthDay: CZDHistoryToday.CZDHistoryEvent.Event = .init(title: titles[1], link: links[1])
                        let content: CZDHistoryToday.CZDHistoryEvent.Event = .init(title: titles[2], link: links[2])
                        let historyEvent: CZDHistoryToday.CZDHistoryEvent = .init(year: year, monthDay: monthDay, content: content)
                        historyTodays.append(historyEvent)
                    }
                    guard historyTodays.count > 0 else {
                        completionHandler(.failure(.dataFault(.noneData)))
                        return
                    }
                    completionHandler(.success(historyTodays))
                } catch let error {
                    completionHandler(.failure(.analysisFault(.otherFault(error))))
                }
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    public func getHistoryToday(completionHandler: @escaping (_ result: Result<[CZDHistoryEvent], ASError>) -> Void) {
        getHistory(date: .init(), completionHandler: completionHandler)
    }
    
    /// 初始化历史上的今天
    public init() {}
    
    /// 初始化历史上的今天
    /// - Parameter timeoutInterval: 超时间隔
    public init(_ timeoutInterval: TimeInterval?) {
        self.timeoutInterval = timeoutInterval
    }
    
}
