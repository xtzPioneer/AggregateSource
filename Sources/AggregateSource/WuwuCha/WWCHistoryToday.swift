import Foundation
import Alamofire
import Kanna

/// 历史上的今天数据源
public protocol WWCHistoryTodayDataSource {
    
    /// 获取历史
    /// - Parameters:
    ///   - date: 时间
    ///   - completionHandler: 完成处理
    func getHistory(date: Date, completionHandler: @escaping (Result<[WWCHistoryToday.HistoryEvent], ASError>) -> Void)
    
    /// 获取历史上的今天
    /// - Parameter completionHandler: 完成处理
    func getHistoryToday(completionHandler: @escaping (Result<[WWCHistoryToday.HistoryEvent], ASError>) -> Void)
    
}

/// 历史上的今天
public final class WWCHistoryToday: ASTimeoutInterval, WWCHistoryTodayDataSource {
    
    /// 根Url
    /// - Returns: Url
    public func rootUrl() -> String {
        "http://today.55cha.com"
    }
    
    /// 历史事件
    public struct HistoryEvent: Codable, Equatable {
        
        /// 标题
        public let title: String
        
        /// 链接
        public let link: String
        
    }
    
    public var timeoutInterval: TimeInterval?
    
    /// 获取历史Url
    /// - Parameters:
    ///   - date: 时间
    ///   - completionHandler: 完成处理
    private func getHistoryURL(date: Date, completionHandler: @escaping (_ result: Result<String, ASError>) -> Void) {
        let urlString = rootUrl()
        let calendar = Calendar.current
        let parameters = [
            "yue": calendar.component(.month, from: date),
            "ri": calendar.component(.day, from: date),
        ]
        AF.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil, requestModifier: timeoutIntervalRequestModifier(request:)).response {
            switch $0.result {
            case .success(let data):
                guard let data = data else {
                    completionHandler(.failure(.dataFault(.noneData)))
                    return
                }
                guard let result = String(data: data, encoding: .utf8) else {
                    completionHandler(.failure(ASError.encodingFault))
                    return
                }
                do {
                    let htmlDocument = try HTML(html: result, encoding: .utf8)
                    let analysisResult = htmlDocument.xpath("/").map({ $0.text! })
                    guard let result = analysisResult.first?.components(separatedBy: "=").last?.components(separatedBy: "\"")[1] else {
                        completionHandler(.failure(ASError.analysisFault(.formatError)))
                        return
                    }
                    let url = "\(urlString)/\(result)"
                    completionHandler(.success(url))
                } catch let error {
                    completionHandler(.failure(.otherFault(error)))
                }
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    /// 获取历史上的今天
    /// - Parameters:
    ///   - url: URL
    ///   - completionHandler: 完成处理
    private func getHistoryToday(url: String, completionHandler: @escaping (_ result: Result<[WWCHistoryToday.HistoryEvent], ASError>) -> Void) {
        AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, requestModifier: { request in
            if let timeoutInterval = self.timeoutInterval { request.timeoutInterval = timeoutInterval }
        }).response {
            switch $0.result {
            case .success(let data):
                guard let data = data else {
                    completionHandler(.failure(ASError.dataFault(.noneData)))
                    return
                }
                guard let result = String(data: data, encoding: .utf8) else {
                    completionHandler(.failure(ASError.encodingFault))
                    return
                }
                do {
                    let htmlDocument = try HTML(html: result, encoding: .utf8)
                    guard let analysisResult = htmlDocument.xpath("//div[@class='mcon']").first?.xpath("/ul/li") else {
                        completionHandler(.failure(ASError.analysisFault(.formatError)))
                        return
                    }
                    var historyEvents = [HistoryEvent]()
                    for item in analysisResult {
                        let `as` = item.xpath("//a")
                        guard `as`.count >= 3, var link = `as`[2]["href"] else {
                            completionHandler(.failure(ASError.analysisFault(.formatError)))
                            return
                        }
                        guard var title = item.text else {
                            completionHandler(.failure(ASError.analysisFault(.dataSourceError)))
                            return
                        }
                        title = title.replacingOccurrences(of: " ", with: "")
                        link = link.replacingOccurrences(of: "./", with: "")
                        link = "\(self.rootUrl())/\(link)"
                        historyEvents.append(.init(title: title, link: link))
                    }
                    guard historyEvents.count > 0 else {
                        completionHandler(.failure(.dataFault(.noneData)))
                        return
                    }
                    completionHandler(.success(historyEvents))
                } catch let error {
                    completionHandler(.failure(.otherFault(error)))
                }
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    public func getHistory(date: Date, completionHandler: @escaping (_ result: Result<[WWCHistoryToday.HistoryEvent], ASError>) -> Void) {
        getHistoryURL(date: date) { [weak self] result in
            switch result {
            case .success(let url):
                self?.getHistoryToday(url: url, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    public func getHistoryToday(completionHandler: @escaping (_ result: Result<[WWCHistoryToday.HistoryEvent], ASError>) -> Void) {
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
