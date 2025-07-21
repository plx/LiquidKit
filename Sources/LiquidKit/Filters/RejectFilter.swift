import Foundation

@usableFromInline
package struct RejectFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "reject"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Handle different input types
        let arrayToFilter: [Token.Value]
        switch token {
        case .array(let array):
            arrayToFilter = array
        case .dictionary:
            // For dictionaries, treat as an array with the dictionary as a single element
            arrayToFilter = [token]
        case .nil:
            // TODO: Should this return nil or empty array?
            return .array([])
        case .string, .integer, .decimal, .bool:
            // Treat single values as single-element arrays
            arrayToFilter = [token]
        case .range:
            // TODO: Should ranges be expanded to arrays?
            arrayToFilter = [token]
        }
        
        guard let firstParameter = parameters.first else {
            // TODO: Should throw an error for missing property parameter
            return .array(arrayToFilter)
        }
        
        let key = firstParameter.stringValue
        
        if parameters.count >= 2 {
            // Reject items where property/value equals the specified value
            let valueToReject = parameters[1]
            
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        return true // Keep items without the property
                    }
                    return propertyValue != valueToReject
                } else {
                    // For non-dictionary items, compare directly if key matches value
                    return item != firstParameter
                }
            }
            
            return .array(filteredArray)
        } else {
            // Reject items where property is truthy or value matches
            let filteredArray = arrayToFilter.filter { item in
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        return true // Keep items without the property
                    }
                    return !propertyValue.isTruthy
                } else {
                    // For non-dictionary items, reject if they match the parameter
                    return item != firstParameter
                }
            }
            
            return .array(filteredArray)
        }
    }
}