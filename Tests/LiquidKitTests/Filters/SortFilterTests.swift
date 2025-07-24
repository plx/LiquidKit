import Testing
@testable import LiquidKit

@Suite("Sort Filter", .tags(.filter, .sortFilter))
struct SortFilterTests {
  private let filter = SortFilter()
  
  // MARK: - Basic Array Sorting
  
  @Test("Sorts string array case-sensitively")
  func sortStringArray() throws {
    // Capital letters should come before lowercase
    try validateEvaluation(
      of: ["b", "a", "B", "A"],
      by: filter,
      yields: ["A", "B", "a", "b"],
      "Capital letters should sort before lowercase"
    )
  }
  
  @Test("Sorts numeric array")
  func sortNumericArray() throws {
    try validateEvaluation(
      of: [30, 1, 1000, 3],
      by: filter,
      yields: [1, 3, 30, 1000]
    )
  }
  
  @Test("Sorts decimal array")
  func sortDecimalArray() throws {
    try validateEvaluation(
      of: [3.14, 1.0, 2.5, 1.1],
      by: filter,
      yields: [1.0, 1.1, 2.5, 3.14]
    )
  }
  
  @Test("Sorts mixed numeric types")
  func sortMixedNumericArray() throws {
    try validateEvaluation(
      of: [3.14, 1, 2.5, 2],
      by: filter,
      yields: [1, 2, 2.5, 3.14]
    )
  }
  
  @Test("Sorts boolean array")
  func sortBooleanArray() throws {
    // false should come before true
    try validateEvaluation(
      of: [true, false, true, false],
      by: filter,
      yields: [false, false, true, true]
    )
  }
  
  // MARK: - Mixed Type Sorting
  
  @Test("Sorts array with nil values")
  func sortArrayWithNil() throws {
    // nil should come first
    try validateEvaluation(
      of: Token.Value.array([.string("hello"), .nil, .integer(5), .nil]),
      by: filter,
      yields: Token.Value.array([.nil, .nil, .integer(5), .string("hello")])
    )
  }
  
  @Test("Sorts mixed type array")
  func sortMixedTypeArray() throws {
    // Order: nil, bool (false then true), numbers, strings
    try validateEvaluation(
      of: Token.Value.array([
        .string("hello"),
        .bool(true),
        .nil,
        .integer(5),
        .bool(false),
        .string("Apple")
      ]),
      by: filter,
      yields: Token.Value.array([
        .nil,
        .bool(false),
        .bool(true),
        .integer(5),
        .string("Apple"),
        .string("hello")
      ])
    )
  }
  
  // MARK: - Property Sorting (New Feature)
  
  @Test("Sorts array of dictionaries by property")
  func sortByProperty() throws {
    let products: [Token.Value] = [
      .dictionary(["name": .string("Shoe"), "price": .integer(30)]),
      .dictionary(["name": .string("Hat"), "price": .integer(10)]),
      .dictionary(["name": .string("Tie"), "price": .integer(5)])
    ]
    
    let expected: [Token.Value] = [
      .dictionary(["name": .string("Tie"), "price": .integer(5)]),
      .dictionary(["name": .string("Hat"), "price": .integer(10)]),
      .dictionary(["name": .string("Shoe"), "price": .integer(30)])
    ]
    
    try validateEvaluation(
      of: Token.Value.array(products),
      with: [.string("price")],
      by: filter,
      yields: Token.Value.array(expected)
    )
  }
  
  @Test("Sorts by string property")
  func sortByStringProperty() throws {
    let items: [Token.Value] = [
      .dictionary(["title": .string("zebra")]),
      .dictionary(["title": .string("octopus")]),
      .dictionary(["title": .string("giraffe")]),
      .dictionary(["title": .string("Sally Snake")])
    ]
    
    let expected: [Token.Value] = [
      .dictionary(["title": .string("Sally Snake")]),
      .dictionary(["title": .string("giraffe")]),
      .dictionary(["title": .string("octopus")]),
      .dictionary(["title": .string("zebra")])
    ]
    
    try validateEvaluation(
      of: Token.Value.array(items),
      with: [.string("title")],
      by: filter,
      yields: Token.Value.array(expected)
    )
  }
  
  @Test("Handles missing property when sorting")
  func sortByMissingProperty() throws {
    let items: [Token.Value] = [
      .dictionary(["name": .string("Item1"), "price": .integer(30)]),
      .dictionary(["name": .string("Item2")]), // Missing price
      .dictionary(["name": .string("Item3"), "price": .integer(10)])
    ]
    
    // Items with missing properties should be treated as nil and come first
    let expected: [Token.Value] = [
      .dictionary(["name": .string("Item2")]),
      .dictionary(["name": .string("Item3"), "price": .integer(10)]),
      .dictionary(["name": .string("Item1"), "price": .integer(30)])
    ]
    
    try validateEvaluation(
      of: Token.Value.array(items),
      with: [.string("price")],
      by: filter,
      yields: Token.Value.array(expected)
    )
  }
  
  @Test("Sorts by property with mixed types")
  func sortByPropertyMixedTypes() throws {
    let items: [Token.Value] = [
      .dictionary(["id": .string("30")]),
      .dictionary(["id": .integer(1)]),
      .dictionary(["id": .string("1000")]),
      .dictionary(["id": .integer(3)])
    ]
    
    // When property values have different types, convert to string for comparison
    let expected: [Token.Value] = [
      .dictionary(["id": .integer(1)]),
      .dictionary(["id": .string("1000")]),
      .dictionary(["id": .integer(3)]),
      .dictionary(["id": .string("30")])
    ]
    
    try validateEvaluation(
      of: Token.Value.array(items),
      with: [.string("id")],
      by: filter,
      yields: Token.Value.array(expected)
    )
  }
  
  // MARK: - Edge Cases
  
  @Test("Returns non-array values unchanged")
  func nonArrayInput() throws {
    try validateEvaluation(
      of: "hello",
      by: filter,
      yields: "hello"
    )
    
    try validateEvaluation(
      of: 42,
      by: filter,
      yields: 42
    )
    
    try validateEvaluation(
      of: true,
      by: filter,
      yields: true
    )
  }
  
  @Test("Handles empty array")
  func emptyArray() throws {
    try validateEvaluation(
      of: [String](),
      by: filter,
      yields: [String]()
    )
  }
  
  @Test("Handles single element array")
  func singleElementArray() throws {
    try validateEvaluation(
      of: ["lonely"],
      by: filter,
      yields: ["lonely"]
    )
  }
  
  @Test("Preserves identical elements")
  func identicalElements() throws {
    try validateEvaluation(
      of: ["a", "a", "a"],
      by: filter,
      yields: ["a", "a", "a"]
    )
  }
  
  @Test("Sorts array with ranges")
  func sortWithRanges() throws {
    // Ranges should be compared as strings when mixed with other types
    try validateEvaluation(
      of: Token.Value.array([
        .string("hello"),
        .range(1...5),
        .integer(3),
        .range(10...15)
      ]),
      by: filter,
      yields: Token.Value.array([
        .range(1...5),
        .range(10...15),
        .integer(3),
        .string("hello")
      ])
    )
  }
  
  @Test("Invalid property parameter")
  func invalidPropertyParameter() throws {
    // When property parameter is not a string, it should be ignored
    let items: [Token.Value] = [
      .dictionary(["name": .string("Item1"), "price": .integer(30)]),
      .dictionary(["name": .string("Item2"), "price": .integer(10)])
    ]
    
    // Should sort the dictionaries themselves, not by property
    try validateEvaluation(
      of: Token.Value.array(items),
      with: [.integer(42)], // Invalid property parameter
      by: filter,
      yields: Token.Value.array(items) // Should return unchanged or sorted by dictionary comparison
    )
  }
}

