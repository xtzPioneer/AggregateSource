import Foundation
import Alamofire
import Kanna

/// 节气数据源
public protocol TTCSolarTermsDataSource {
    
    /// 获取节气
    /// - Parameters:
    ///   - year: 年
    ///   - completionHandler: 完成处理
    func getSolarTerms(year: Int, completionHandler: @escaping (Result<[TTCSolarTerms.SolarTermsData], ASError>) -> Void)
    
}

/// 节气
public final class TTCSolarTerms: ASTimeoutInterval, TTCSolarTermsDataSource {
    
    /// 节气数据
    public struct SolarTermsData: Codable, Equatable {
        
        /// 名称
        public let name: String
        
        /// 图片Url
        public let imageUrl: String
        
        /// 描述
        public let describe: String
        
        /// 时间
        public let date: String
        
    }
    
    public var timeoutInterval: TimeInterval?
    
    /// 节气Url
    /// - Parameter year: 年
    /// - Returns: Url
    private func url(year: Int) -> String {
        "http://jieqi.ttcha.net/\(year).html"
    }
    
    /// 获取节气
    /// - Parameters:
    ///   - url: Url
    ///   - completionHandler: 完成处理
    private func getSolarTerms(url: String, completionHandler: @escaping (Result<[TTCSolarTerms.SolarTermsData], ASError>) -> Void) {
        AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, requestModifier: timeoutIntervalRequestModifier(request:)).response {
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
                    guard let analysisResult = htmlDocument.xpath("//div[@class='appContent']").first?.xpath("/ul/li/a") else {
                        completionHandler(.failure(ASError.analysisFault(.formatError)))
                        return
                    }
                    var solarTermsDatas = [SolarTermsData]()
                    analysisResult.forEach { element in
                        let spans = element.xpath("/span")
                        guard spans.count >= 3,
                              let name = element.xpath("//span[@class='title']").first?.text,
                              let imageUrl = element.xpath("/img/@src").first?.text,
                              let describe = spans[1].text,
                              let date = spans[2].text else { return }
                        solarTermsDatas.append(
                            .init(
                                name: name,
                                imageUrl: imageUrl,
                                describe: describe,
                                date: date
                            )
                        )
                    }
                    guard solarTermsDatas.count > 0 else {
                        completionHandler(.failure(.dataFault(.noneData)))
                        return
                    }
                    completionHandler(.success(solarTermsDatas))
                } catch let error {
                    completionHandler(.failure(.analysisFault(.otherFault(error))))
                }
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    public func getSolarTerms(year: Int, completionHandler: @escaping (_ result: Result<[TTCSolarTerms.SolarTermsData], ASError>) -> Void) {
        getSolarTerms(url: url(year: year), completionHandler: completionHandler)
    }
    
    /// 初始化节气
    public init() {}
    
    /// 初始化节气
    /// - Parameter timeoutInterval: 超时间隔
    public init(_ timeoutInterval: TimeInterval?) {
        self.timeoutInterval = timeoutInterval
    }
    
}
