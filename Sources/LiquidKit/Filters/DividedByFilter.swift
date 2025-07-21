import Foundation
import Darwin

struct DividedByFilter: Filter {
    static let filterIdentifier = "divided_by"
    
    init() {}
    
    func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard let dividendDouble = token.doubleValue, let divisor = parameters.first else {
            return .nil
        }
        
        switch divisor {
        case .integer(let divisorInt):
            return .integer(Int(Darwin.floor(dividendDouble / Double(divisorInt))))
            
        case .decimal:
            guard let divisorDouble = divisor.doubleValue else {
                return .nil
            }
            return .decimal(Decimal(dividendDouble / divisorDouble))
            
        default:
            return .nil
        }
    }
}