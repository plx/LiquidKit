import Foundation

@usableFromInline
package struct FindFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "find"
    
    @inlinable
    package init() {}
    
    @inlinable
    package func evaluate(token: Token.Value, parameters: [Token.Value]) throws -> Token.Value {
        // Handle different input types
        let arrayToSearch: [Token.Value]
        switch token {
        case .array(let array):
            arrayToSearch = array
        case .dictionary:
            // For dictionaries, treat as an array with the dictionary as a single element
            arrayToSearch = [token]
        case .nil:
            // TODO: Should this return nil or empty array?
            return .nil
        case .string, .integer, .decimal, .bool:
            // Treat single values as single-element arrays
            arrayToSearch = [token]
        case .range:
            // TODO: Should ranges be expanded to arrays?
            arrayToSearch = [token]
        }
        
        guard let firstParameter = parameters.first else {
            // TODO: Should throw an error for missing property parameter
            return .nil
        }
        
        let key = firstParameter.stringValue
        
        if parameters.count >= 2 {
            // Find first item where property/value equals the specified value
            let valueToMatch = parameters[1]
            
            for item in arrayToSearch {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue == valueToMatch {
                        return item
                    }
                } else {
                    // For non-dictionary items, compare directly if key matches value
                    if item == firstParameter {
                        return item
                    }
                }
            }
            
            return .nil
        } else {
            // Find first item where property is truthy or value matches
            for item in arrayToSearch {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue.isTruthy {
                        return item
                    }
                } else {
                    // For non-dictionary items, select if they match the parameter
                    if item == firstParameter {
                        return item
                    }
                }
            }
            
            return .nil
        }
    }
}