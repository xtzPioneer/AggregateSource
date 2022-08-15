import Foundation

/// 超时时间间隔
public protocol ASTimeoutInterval {
    
    /// 超时间隔
    var timeoutInterval: TimeInterval? { get set }
    
    /// 初始化
    /// - Parameter timeoutInterval: 超时间隔
    init(_ timeoutInterval: TimeInterval?)
    
}


