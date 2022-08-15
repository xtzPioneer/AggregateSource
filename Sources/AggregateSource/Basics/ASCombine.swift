import Foundation
import Combine
import CombineExt

extension PassthroughSubject {
    
    /// 发布结果
    /// - Parameter result: 结果
    func publisherResult(_ result: Result<PassthroughSubject.Output, PassthroughSubject.Failure>) -> Void {
        switch result {
        case .success(let data):
            self.send(data)
            self.send(completion: .finished)
        case .failure(let error):
            self.send(completion: .failure(error))
        }
    }
    
}


