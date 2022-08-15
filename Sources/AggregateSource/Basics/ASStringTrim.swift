import Foundation

extension String {
    
    /// 修剪
    /// - Returns: 字符串
    public func trim() -> String { trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
    
}
