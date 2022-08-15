import Foundation

extension ASTimeoutInterval {
    
    /// 超时间隔请求修饰符
    /// - Parameter request: 请求
    func timeoutIntervalRequestModifier(request: inout URLRequest) throws -> Void  {
        if let timeoutInterval = self.timeoutInterval { request.timeoutInterval = timeoutInterval }
    }
    
}

