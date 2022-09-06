import Foundation
import Alamofire
import Kanna
import SwiftDate

/// 老黄历年鉴数据源
public protocol LHLAlmanacDataSource {
    
    /// 获取年鉴
    /// - Parameters:
    ///   - year: 年
    ///   - month: 月
    ///   - completionHandler: 完成处理
    func getAlmanac(date: Date, completionHandler: @escaping (Result<LHLAlmanac.LHLData, ASError>) -> Void)
    
}

/// 老黄历年鉴
public final class LHLAlmanac: ASTimeoutInterval, LHLAlmanacDataSource {
    
    /// 年鉴数据
    public struct LHLData: Codable, Equatable {
        
        /// 黄历时间
        public let gzDate: GZDate
        
        /// 神仙
        public let immortal: Immortal
        
        /// 节气
        public let solarTermss: [SolarTerms]
        
        /// 适宜
        public let suit: SAContent
        
        /// 忌讳
        public let avoid: SAContent
        
        /// 百忌与相冲
        public let adrshs: [DTContent]
        
        /// 胎神
        public let fetusImmortals: [DTContent]
        
        /// 吉神宜趋
        public let agsbi: DTContent
        
        /// 凶煞宜忌
        public let fsba: DTContent
        
        /// 月名、月相、日禄、物候、岁煞
        public let mxlws: [DTContent]
        
        /// 财神位、阴阳贵神、空亡所值
        public let cyks: [CYKContent]
        
        /// 九宫飞星
        public let jgfx: JGFXContent
        
        /// 信息
        public let info: IFContent
        
    }
    
    /// 内容
    public struct IFContent: Codable, Equatable {
        
        /// 阳历时间
        public let ylDate: String
        
        /// 农历时间
        public let nlDate: String
        
        /// 时间
        public let mdDate: String
        
        /// 农历天数
        public let nlDayNumbers: String
        
        /// 已逝天数
        public let deadDayNumbers: String
        
    }
    
    /// 内容
    public struct JGFXContent: Codable, Equatable {
        
        /// 标题
        public let title: String
        
        /// 子集
        public let children: [String]
        
    }
    
    /// 内容
    public struct CYKContent: Codable, Equatable {
        
        /// 标题
        public let title: String
        
        /// 子集
        public let children: [DTContent]
        
    }
    
    /// 内容
    public struct DTContent: Codable, Equatable {
        
        /// 标题
        public let title: String
        
        /// 描述
        public let describe: String
        
        /// 初始化内容
        /// - Parameters:
        ///   - title: 标题
        ///   - describe: 描述
        public init(title: String, describe: String) {
            self.title = title
            self.describe = describe
        }
        
    }
    
    /// 适宜与忌讳的内容
    public struct SAContent: Codable, Equatable {
        
        /// 标题
        public let title: String
        
        /// 注意
        public let careful: String?
        
        /// 子集
        public let children: [String]
        
    }
    
    /// 节气
    public struct SolarTerms: Codable, Equatable {
        
        /// 名称
        public let name: String
        
        /// 日期
        public let date: String
        
    }
    
    /// 神仙
    public struct Immortal: Codable, Equatable {
        
        /// 五行
        public let wx: DTContent
        
        /// 神仙
        public let immortal: DTContent
        
        /// 执事
        public let deacon: DTContent
        
    }
    
    /// 黄历时间
    public struct GZDate: Codable, Equatable {
        
        /// 年
        public let year: Content
        
        /// 月
        public let month: Content
        
        /// 日
        public let day: Content
        
        /// 内容
        public struct Content: Codable, Equatable {
            
            /// 名称
            public let name: String
            
            /// 生肖
            public let animal: String
            
            /// 属性
            public let attribute: String
            
        }
        
    }
    
    public var timeoutInterval: TimeInterval?
    
    /// Url
    /// - Parameter date: 时间
    /// - Returns: Url
    private func url(_ date: Date) -> String {
        "https://www.laohuangli.net/\(date.year)/\(date.year)-\(date.month)-\(date.day).html"
    }
    
    public func getAlmanac(date: Date, completionHandler: @escaping (_ result: Result<LHLData, ASError>) -> Void) {
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
                    // 解析农历
                    let analysisGzDate: (HTMLDocument) -> GZDate? = { htmlDocument in
                        guard let xpaths = htmlDocument.xpath("//table/tbody/tr/td").first?.xpath("/div").map({ $0.xpath("//span") }) else { return nil }
                        let minCount = 3
                        let contents = xpaths.map { obj -> GZDate.Content? in
                            guard obj.count >= minCount, let name = obj[0].text, let animal = obj[1].text, let attribute = obj[2].text else { return nil }
                            return .init(name: name, animal: animal, attribute: attribute)
                        }
                        guard contents.count >= minCount, let year = contents[0], let month = contents[1], let day = contents[2] else { return nil }
                        return .init(year: year, month: month, day: day)
                    }
                    // 解析神仙
                    let analysisImmortal: (HTMLDocument) -> Immortal? = { htmlDocument in
                        let xpaths = htmlDocument.xpath("//table/tbody/tr/td")
                        guard xpaths.count >= 3 else { return nil }
                        let minCount = 3
                        let spans = xpaths[2].xpath("/div").map({ $0.xpath("//span") })
                        let contents = spans.map { obj -> DTContent? in
                            guard obj.count >= 2, let name = obj[0].text, let describe = obj[1].text else { return nil }
                            return .init(title: name, describe: describe)
                        }
                        guard contents.count >= minCount, let wx = contents[0], let immortal = contents[1], let deacon = contents[2] else { return nil }
                        return .init(wx: wx, immortal: immortal, deacon: deacon)
                    }
                    // 解析节气
                    let analysisSolarTermss: (HTMLDocument) -> [SolarTerms]? = { htmlDocument in
                        guard let rawSolarTermss = htmlDocument.xpath("//table/tbody/tr[@class='text-p']").first?.xpath("/td").map({ obj -> LHLAlmanac.SolarTerms? in
                            guard let text = obj.text else { return nil }
                            let texts = text.dropFirst(2).components(separatedBy: ":")
                            guard texts.count >= 2 else { return nil }
                            return .init(name: texts[0], date: texts[1])
                        }) else { return nil }
                        var solarTermss: [SolarTerms] = []
                        rawSolarTermss.forEach { item in
                            guard let item = item else { return }
                            solarTermss.append(item)
                        }
                        return solarTermss.count != 0 ? solarTermss : nil
                    }
                    // 解析适宜于忌讳
                    let analysisSuitOrAvoid: (HTMLDocument) -> (suit: SAContent?, avoid: SAContent?) = { htmlDocument in
                        let contents = htmlDocument.xpath("//tr/td/div[@class='table-three-div']").map { element -> SAContent? in
                            guard let title = element.xpath("//h3").first?.text else { return nil }
                            let children = element.xpath("//p/span").map { element -> String? in element.text }.filter({ $0 != nil }).map({ $0!.trim() })
                            var careful = element.xpath("//p//text()").first?.text?.trim();
                            careful = careful?.count ?? 0 > 0 ? careful : nil
                            return .init(title: title, careful: careful, children: children)
                        }
                        return (contents.first ?? nil, contents.last ?? nil)
                    }
                    // 解析百忌与相冲和胎神
                    let analysisAdrshsOrFetusImmortals: (HTMLDocument) -> (adrsh: [DTContent]?, fetusImmortal: [DTContent]?) = { htmlDocument in
                        let contents = htmlDocument.xpath("//div[@class='col-td2 col-td3']").map { element -> DTContent? in
                            let array = element.xpath("/span")
                            guard array.count >= 2, let title = array[0].text, let describe = array[1].text else { return nil }
                            return .init(title: title, describe: describe)
                        }
                        var adrshs: [DTContent] = []
                        var fetusImmortals: [DTContent] = []
                        for (index, item) in contents.enumerated() {
                            if (item != nil && index >= 0 && index <= 1 ) {
                                adrshs.append(item!)
                            } else if (item != nil && index >= 2 && index <= 3 ) {
                                fetusImmortals.append(item!)
                            }
                        }
                        return (adrshs.count > 0 ? adrshs : nil, fetusImmortals.count > 0 ? fetusImmortals : nil)
                    }
                    // 解析吉神宜趋与凶煞宜忌
                    let analysisAgsbiOrFsba: (HTMLDocument) -> (agsbi: DTContent?, fsba: DTContent?) = { htmlDocument in
                        let contents = htmlDocument.xpath("//div[@class='table-five-div']").map { element -> DTContent? in
                            guard let title = element.xpath("//div").first?.text, let describe = element.xpath("//span").first?.text else { return nil }
                            return .init(title: title, describe: describe)
                        }.filter({ $0 != nil }).map({ $0! })
                        return (contents.first, contents.last)
                    }
                    // 解析月名、月相、日禄、物候、岁煞
                    let analysisMxlws: (HTMLDocument) -> [DTContent]? = { htmlDocument in
                        let xpaths = htmlDocument.xpath("//div[@class='t-left']")
                        guard  let texts = xpaths.first?.xpath("//tr/td/span").map({ element -> String? in element.text }).filter({ $0 != nil }).map({ $0! }), texts.count % 2 == 0 else { return nil }
                        var contents = [DTContent]()
                        var titles = [String]()
                        var describes = [String]()
                        for (index, item) in texts.enumerated() {
                            if index % 2 == 0 {
                                titles.append(item)
                            } else {
                                describes.append(item)
                            }
                        }
                        for index in 0..<titles.count {
                            contents.append(.init(title: titles[index], describe: describes[index]))
                        }
                        return contents
                    }
                    // 解析财神位、阴阳贵神、空亡所值
                    let analysisCyks: (HTMLDocument) -> [CYKContent]? = { htmlDocument in
                        let xpaths = htmlDocument.xpath("//td/div[@class='img-box']")
                        var contents = xpaths.map { element -> CYKContent? in
                            guard let title = element.xpath("//div").first?.text else { return nil }
                            let contents = element.xpath("//li").map({ element -> DTContent? in
                                let texts = element.xpath("//text()").map { element -> String? in
                                    return element.text
                                }.filter({ $0 != nil }).map({ $0! })
                                guard texts.count == 2 else { return nil }
                                return .init(title: texts.first!, describe: texts.last!)
                            }).filter({ $0 != nil }).map({ $0! })
                            return .init(title: title, children: contents)
                        }.filter({ $0 != nil }).map({ $0! })
                        contents.removeLast()
                        return contents.count > 0 ? contents : nil
                    }
                    // 解析九宫飞星
                    let analysisJgfx: (HTMLDocument) -> JGFXContent? = { htmlDocument in
                        let xpaths = htmlDocument.xpath("//td/div[@class='img-box']")
                        guard xpaths.count >= 4, let title = xpaths[3].xpath("//div").first?.text else { return nil }
                        let texts = xpaths[3].xpath("//p//text()").map { element -> String? in
                            element.text?.trim()
                        }.filter { ($0 != nil && $0 != "") }.map({ $0! })
                        return .init(title: title, children: texts)
                    }
                    // 解析信息
                    let analysisInfo: (HTMLDocument) -> IFContent? = { htmlDocument in
                        guard let xpath1 = htmlDocument.xpath("//div[@class='middle-rowspan']").first else { return nil }
                        guard let xpath2 = htmlDocument.xpath("//td[@class='bg-white t-left']").first else { return nil }
                        guard let ylDate = xpath1.xpath("//p").first?.text else { return nil }
                        guard let mdDate = xpath1.xpath("//div[@class='page-btn-box']/span").first?.text else { return nil }
                        guard let nlDate = xpath1.xpath("//p[@class='p-relative']").first?.text else { return nil }
                        let xpaths = xpath2.xpath("//p//text()")
                        guard xpaths.count >= 3, let nlDayNumbers = xpaths[0].text, let deadDayNumbers = xpaths[2].text else { return nil }
                        return .init(
                            ylDate: ylDate.trim(),
                            nlDate: nlDate.trim(),
                            mdDate: mdDate.trim(),
                            nlDayNumbers: nlDayNumbers.trim(),
                            deadDayNumbers: deadDayNumbers.trim()
                        )
                    }
                    // 组装数据
                    let gzDate = analysisGzDate(htmlDocument)
                    let immortal = analysisImmortal(htmlDocument)
                    let solarTermss = analysisSolarTermss(htmlDocument)
                    let suitOrAvoid = analysisSuitOrAvoid(htmlDocument)
                    let adrshsOrFetusImmortals = analysisAdrshsOrFetusImmortals(htmlDocument)
                    let agsbiOrFsba = analysisAgsbiOrFsba(htmlDocument)
                    let mxlws = analysisMxlws(htmlDocument)
                    let cyks = analysisCyks(htmlDocument)
                    let jgfx = analysisJgfx(htmlDocument)
                    let info = analysisInfo(htmlDocument)
                    guard let gzDate = gzDate,
                          let immortal = immortal,
                          let solarTermss = solarTermss,
                          let suit = suitOrAvoid.suit,
                          let avoid = suitOrAvoid.avoid,
                          let adrshs = adrshsOrFetusImmortals.adrsh,
                          let fetusImmortals = adrshsOrFetusImmortals.fetusImmortal,
                          let agsbi = agsbiOrFsba.agsbi,
                          let fsba = agsbiOrFsba.fsba,
                          let mxlws = mxlws,
                          let cyks = cyks,
                          let jgfx = jgfx,
                          let info = info
                    else {
                        completionHandler(.failure(.analysisFault(.dataSourceError)))
                        return
                    }
                    let data: LHLData = .init(
                        gzDate: gzDate,
                        immortal: immortal,
                        solarTermss: solarTermss,
                        suit: suit,
                        avoid: avoid,
                        adrshs: adrshs,
                        fetusImmortals: fetusImmortals,
                        agsbi: agsbi,
                        fsba: fsba,
                        mxlws: mxlws,
                        cyks: cyks,
                        jgfx: jgfx,
                        info: info
                    )
                    completionHandler(.success(data))
                } catch let error {
                    completionHandler(.failure(.analysisFault(.otherFault(error))))
                }
            case .failure(let error):
                completionHandler(.failure(.netFault(error)))
            }
        }
    }
    
    
    /// 初始化老黄历年鉴
    /// - Parameter timeoutInterval: 超时间隔
    public init(_ timeoutInterval: TimeInterval?) {
        self.timeoutInterval = timeoutInterval
    }
    
    /// 初始化老黄历年鉴
    public init() {}
    
}
