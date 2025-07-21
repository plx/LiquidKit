import Foundation

@usableFromInline
package struct FindIndexFilter: Filter {
    @usableFromInline
    package static let filterIdentifier = "find_index"
    
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
            // TODO: Should this return nil or throw an error?
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
            // Find index of first item where property/value equals the specified value
            let valueToMatch = parameters[1]
            
            for (index, item) in arrayToSearch.enumerated() {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check the property value
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue == valueToMatch {
                        return .integer(index)
                    }
                } else {
                    // For non-dictionary items (strings), check if the search string is contained
                    if case .string(let str) = item, str.contains(key) {
                        return .integer(index)
                    }
                }
            }
            
            return .nil
        } else {
            // Find index of first item where property is truthy or value matches
            for (index, item) in arrayToSearch.enumerated() {
                if case .dictionary(let dict) = item {
                    // For dictionaries, check if property is truthy
                    guard let propertyValue = dict[key] else {
                        continue // Skip items without the property
                    }
                    if propertyValue.isTruthy {
                        return .integer(index)
                    }
                } else {
                    // For non-dictionary items (strings), check if the search string is contained
                    if case .string(let str) = item, str.contains(key) {
                        return .integer(index)
                    }
                }
            }
            
            return .nil
        }
    }
}