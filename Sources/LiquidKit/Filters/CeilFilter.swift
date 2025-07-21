import Foundation
import Darwin

struct CeilFilter: Filter {
    static let filterIdentifier = "ceil"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let inputDouble = token.doubleValue else {
            return .nil
        }
        
        return .decimal(Decimal(Int(Darwin.ceil(inputDouble))))
    }
}