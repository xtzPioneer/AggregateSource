import Foundation

/// 错误
public enum ASError: Error {
    
    /// 数据故障
    public enum DataFault {
        
        /// 没有数据
        case noneData
        
        /// 残缺数据
        case incompleteData
        
        /// 格式错误
        case formatError
        
        /// 类型错误
        case typeError
        
        /// 其他故障
        case otherFault(Error)
        
    }
    
    /// 参数故障
    public enum ParametersFault {
        
        /// 没有参数
        case noneParameters
        
        /// 参数缺失
        case incompleteParameters
        
        /// 格式错误
        case formatError
        
        /// 类型错误
        case typeError
        
        /// 其他故障
        case otherFault(Error)
        
    }
    
    /// 解析故障
    public enum AnalysisFault {
        
        /// 数据源错误
        case dataSourceError
        
        /// 格式错误
        case formatError
        
        /// 类型错误
        case typeError
        
        /// 其他故障
        case otherFault(Error)
        
    }
    
    /// 数据故障
    case dataFault(DataFault)
    
    /// 参数故障
    case parametersFault(ParametersFault)
    
    /// 解析故障
    case analysisFault(AnalysisFault)
    
    /// 编码故障
    case encodingFault
    
    /// 解码故障
    case decodeFault
    
    /// 网络故障
    case netFault(Error)
    
    /// 系统故障
    case systemFault(Error)
    
    /// 其他故障
    case otherFault(Error)
    
}

