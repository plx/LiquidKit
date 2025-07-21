import Foundation

public struct SortFilter: Filter {
    public static let filterIdentifier = "sort"
    
    public init() {}
    
    public func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        guard case .array(let array) = token else {
            return token
        }
        
        let sortedArray = array.sorted { (lhs, rhs) -> Bool in
            switch (lhs, rhs) {
            case (.nil, _):
                return true
            case (_, .nil):
                return false
            case (.bool(let l), .bool(let r)):
                return !l && r
            case (.integer(let l), .integer(let r)):
                return l < r
            case (.decimal(let l), .decimal(let r)):
                return l < r
            case (.integer(let l), .decimal(let r)):
                return Decimal(l) < r
            case (.decimal(let l), .integer(let r)):
                return l < Decimal(r)
            case (.string(let l), .string(let r)):
                return l < r
            default:
                // For mixed types, convert to string and compare
                return lhs.stringValue < rhs.stringValue
            }
        }
        
        return .array(sortedArray)
    }
}