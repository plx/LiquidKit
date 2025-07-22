# LiquidKit - Project Overview and Development Guide

## Project Summary

LiquidKit is a Swift implementation of the Liquid template language, originally developed by Shopify and commonly used in Jekyll static sites and Shopify themes. This is a fork of an abandoned repository that has been modernized with Swift 6, providing a complete, native Swift framework for parsing and rendering Liquid templates across all Apple platforms.

### Key Features
- Complete implementation of Liquid template syntax
- All standard Liquid tags (if/else, for, case/when, capture, etc.)
- All standard Liquid filters (capitalize, date, replace, etc.)
- Support for custom filters and tags
- Type-safe value system with proper nil handling
- Dot notation for nested data access
- Thread-safe with Swift 6 concurrency support
- Compatible with iOS 13.0+, macOS 10.15+, watchOS 6.0+, tvOS 13.0+

## Architecture Overview

The library follows a classic three-phase template engine architecture:

### 1. Lexing Phase (`Lexer.swift`)
- Scans template strings for `{{...}}` (output) and `{%...%}` (tags)
- Creates tokens representing text, variables, and tags
- Handles special cases like raw blocks and comments

### 2. Parsing Phase (`Parser.swift`)
- Processes tokens into an executable node tree
- Compiles tags, filters, and operators
- Manages variable context and scope
- Validates syntax and structure

### 3. Rendering Phase
- Executes the parsed template with provided context
- Applies filters to transform values
- Handles control flow (loops, conditionals)
- Outputs final rendered string

### Core Components

- **Token.swift**: Defines the value system (nil, bool, string, integer, decimal, array, dictionary, range)
- **Context.swift**: Container for template variables and execution state
- **Filter Protocol**: Protocol-based system for transforming values (as of latest refactoring)
- **Individual Filter Implementations**: 47 separate filter structs in `Filters/` directory
- **Tag.swift**: Base class and implementations for all Liquid tags
- **Operator.swift**: Comparison and logical operators (==, !=, >, <, contains, etc.)

## Current State

### Recent Architecture Changes
- **Filter System** (Latest): Migrated from class-based to protocol-based architecture
  - 47 built-in filters now implemented as individual structs conforming to `Filter` protocol
  - Improved type safety and maintainability
  - Each filter in its own file under `Filters/` directory

### Swift Version
- **Swift 6** with strict concurrency checking enabled
- Modern Swift string handling and native APIs
- Full concurrency support with @Sendable conformance

### Dependencies
1. **swift-html-entities** - For HTML entity encoding/decoding (via Swift Package Manager)
   - Source: https://github.com/Kitura/swift-html-entities

### Build System
- Uses Swift Package Manager (SPM)
- Cross-platform support for all Apple platforms
- No external build tool dependencies

## Testing Strategy

### Existing Test Suite
The project has good test coverage with tests for:
- All standard filters
- All standard tags  
- Parser edge cases
- Operator behavior

### Golden Liquid Integration
We've integrated the [golden-liquid](https://github.com/jg-rp/golden-liquid) test suite - a comprehensive, standardized test format with 1012 test cases that validates Liquid template engine implementations. This provides:
- Spec compliance tracking
- Data-driven tests using Swift Testing
- Detailed diagnostics for failures
- Tag-based test filtering

See `guides/GoldenLiquid.md` for detailed documentation on the test infrastructure.

When modernizing, ensure:
1. All existing tests pass
2. Add tests for any new Swift 6 features
3. Test on minimum deployment targets
4. Benchmark performance improvements
5. Run golden-liquid tests to track spec compliance

## Quick Start Commands

```bash
# Build the project
swift build

# Run tests
swift test

# Build documentation
swift package generate-documentation --product LiquidKit

# Preview documentation in browser
swift package --disable-sandbox preview-documentation --product LiquidKit

# Use in Xcode
open Package.swift
```

## Project Structure

```
LiquidKit/
├── Package.swift                     # SPM manifest
├── Sources/
│   └── LiquidKit/
│       ├── Lexer.swift               # Template tokenization
│       ├── Parser.swift              # Token parsing and compilation
|       ├── Filter.swift              # Filter protocol definition  
|       ├── Filter+Conveniences.swift # Filter protocol helper methods
│       ├── Filters/                  # Filter system (47 individual filter implementations)
│       │   ├── 
│       │   ├── AbsFilter.swift
│       │   ├── AppendFilter.swift
│       │   └── ... (44 more filter implementations)
│       ├── Tag.swift                   # All tag implementations
│       ├── Token.swift                 # Value type system
│       ├── Context.swift               # Variable storage and scope
│       ├── Operator.swift              # Comparison and logical operators
│       ├── Operator+Conveniences.swift # Operator protocol helper methods
│       ├── Error.swift                 # Error types
│       └── Extensions/                 # String and Double extensions
├── Tests/
│   └── LiquidKitTests/      # Comprehensive test suite
│       ├── Resources/        # Test resources
│       │   └── golden_liquid.json  # 1012 golden-liquid test cases
│       ├── GoldenLiquid*.swift     # Golden-liquid test infrastructure
│       └── [existing tests]
├── guides/
│   └── GoldenLiquid.md      # Golden-liquid integration guide
└── previous/                 # Original CocoaPods structure (reference only)

## Known Issues and Limitations

Based on golden-liquid test suite analysis:

### Missing Tags (with test count)
- `echo tag` - 29 tests (basic output tag)
- `liquid tag` - 19 tests (inline Liquid syntax)  
- `render tag` - 17 tests (isolated scope rendering)
- `tablerow tag` - 15 tests (HTML table generation)
- `cycle tag` - 12 tests (cycling through values)
- `increment tag` - 9 tests (counter management)
- `ifchanged tag` - 5 tests (change detection)
- `decrement tag` - 4 tests (counter management)

### Implementation Gaps
1. **Array Indexing**: Variable array indexing not supported (e.g., `array[i]` where i is a variable)
2. **Bracket Notation**: Object property access via brackets not supported (e.g., `obj['key']`)
3. **Filter Validation**: Extra filter arguments don't cause errors as they should
4. **Range Output**: Range objects don't render properly when output directly
5. **Error Handling**: Some edge cases don't match Liquid's strict error behavior
6. **Filter Error Reporting**: Filter protocol now supports throwing errors, but not all filters validate inputs (e.g., division by zero should throw but currently returns nil)

### Other Limitations
1. **Documentation**: Could benefit from more inline documentation and usage examples
2. **Performance**: Some recursive parsing patterns could potentially be optimized
3. **External Templates**: The `templates` field for include/render not fully utilized

## Resources

- [Liquid Documentation](https://shopify.github.io/liquid/)
- [Swift Evolution](https://www.swift.org/swift-evolution/)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Swift 6 Migration Guide](https://www.swift.org/migration/swift-6/)

## Lessons Learned from Modernization

### 1. Dependency Migration Strategy
- **STRFTimeFormatter Replacement**: When replacing C-based date formatting libraries, mapping strftime format specifiers to DateFormatter patterns is straightforward. The key patterns we needed were:
  - `%Y` → `yyyy`, `%m` → `MM`, `%d` → `dd`
  - `%H` → `HH`, `%M` → `mm`, `%S` → `ss`
  - Special cases like `%j` (day of year) require DateFormatter with specific formats
- **Lesson**: Don't over-engineer replacements for thin C wrappers - a simple mapping often suffices

### 2. CocoaPods to SPM Migration
- **File Organization**: Moving files to a `previous/` directory preserved history while allowing clean SPM structure
- **Import Fixes**: Many files were missing explicit `import Foundation` statements that CocoaPods was auto-including
- **Lesson**: Test compilation immediately after moving files to catch missing imports early

### 3. Foundation API Modernization
- **NSString → String**: Most NSString usage was unnecessary; Swift's native String with proper Range handling is cleaner
- **NSRegularExpression**: Keep for complex patterns - Swift Regex requires iOS 16+ which would limit compatibility
- **Lesson**: Not all Foundation usage needs removal - evaluate each case for compatibility vs. modernization benefits

### 4. Safety Improvements
- **Force Unwrapping**: Each `!` needed individual analysis - some were truly safe, others hid edge cases
- **try! Replacement**: Static regex patterns can use lazy initialization with proper error handling
- **Lesson**: Address safety issues incrementally with testing after each change to ensure behavior preservation

### 5. Swift 6 Concurrency
- **Sendable Design**: Value types (`Token`, `Lexer`) are naturally Sendable; reference types need careful consideration
- **@unchecked Sendable**: Use for immutable classes where the compiler can't verify safety
- **Non-Sendable Types**: `Context` and `Parser` have mutable state - document they're for single-threaded use
- **Lesson**: Not everything needs to be Sendable - be intentional about concurrency boundaries

### 6. Testing During Migration
- **Incremental Testing**: Run tests after each file change, not just at phase completion
- **Test Discovery**: SPM's test discovery found tests that weren't in the Xcode project
- **Lesson**: Frequent testing catches issues early and makes debugging easier

### 7. Performance Considerations
- **String Operations**: Native Swift String is often faster than NSString bridging
- **Set vs NSOrderedSet**: Pure Swift implementation with Array + Set is cleaner and performs well
- **Lesson**: Modern Swift often provides better performance than old Foundation APIs

### 8. Swift Testing Integration
- **Data-Driven Tests**: Swift Testing's `@Test` with arguments is perfect for test suites like golden-liquid
- **Resource Management**: Test resources go in `Tests/TestTarget/Resources/` with `.copy("Resources")` in Package.swift
- **JSON to Swift Types**: Create intermediate enums for flexible JSON decoding before converting to domain types
- **Test Organization**: Group related tests by feature/tag for better test execution control
- **Lesson**: Swift Testing's parameterized tests scale well - we successfully integrated 1012 test cases

### 9. Test Suite Adoption Strategy
- **Incremental Approach**: Start with parsing tests, then loading, then validation
- **Safe Execution**: Wrap test execution in do/catch to prevent crashes during exploration
- **Feature Discovery**: Use test analysis to identify missing features before implementation
- **Detailed Diagnostics**: Include all relevant context in test failure messages
- **Lesson**: Comprehensive test suites reveal implementation gaps quickly and provide a clear roadmap

### 10. Protocol-Based Architecture Migration
- **Filter System Refactoring**: Successfully migrated from class-based to protocol-based filter system
- **Type Annotations**: When converting classes to protocols, update all type annotations to use `any ProtocolName`
- **Method Invocation**: Changed from closure property (`filter.lambda`) to protocol method (`filter.evaluate`)
- **Parallel Migration Strategy**: For large-scale migrations (47 filters), use subagents for parallel processing
- **Template Pattern**: Create one example implementation first to establish patterns before bulk migration
- **File Organization**: Individual implementations in separate files improves maintainability and compilation
- **Import Management**: Some filters need specific imports (Darwin for math, HTMLEntities for escaping)
- **Testing Strategy**: Run individual filter tests during migration rather than full suite to avoid noise
- **Error Handling Evolution**: Protocol now supports `throws`, enabling future error reporting improvements
- **Backward Compatibility**: Protocol migration maintained 100% API compatibility - all tests passed unchanged
- **Lesson**: Large architectural changes can be done safely with methodical approach and comprehensive testing

## Contributing Guidelines

1. Maintain backward compatibility where possible
2. Add tests for any new functionality
3. Follow existing code style and patterns
4. Document public APIs thoroughly
5. Consider performance implications
6. Ensure thread safety for Swift 6

## Contact and Support

This is a modernized fork of an abandoned project, now fully updated for Swift 6:
- Open issues in the GitHub repository for bugs or feature requests
- Submit pull requests with tests (all PRs must pass the test suite)
- Check existing issues before creating new ones
- For usage questions, refer to the [Liquid Documentation](https://shopify.github.io/liquid/)

## Usage Example

```swift
import LiquidKit

// Create a template
let template = "Hello {{ name }}! Today is {{ 'now' | date: '%A, %B %d, %Y' }}."

// Parse the template
let lexer = Lexer(templateString: template)
let tokens = lexer.tokenize()
let parser = Parser(tokens: tokens, context: Context())
let nodes = try parser.parse()

// Render with context
let context = Context(dictionary: ["name": "World"])
let output = renderer.render(nodes: nodes, context: context)
// Output: "Hello World! Today is Monday, January 18, 2025."
```

## Important Notes

- **Thread Safety**: `Token`, `Lexer`, all filter structs, and operator types are thread-safe. `Context` and `Parser` should be used on a single thread.
- **Migration Path**: Projects using the old CocoaPods version can migrate by updating imports and switching to SPM
- **Platform Requirements**: Requires iOS 13.0+, macOS 10.15+, or equivalent versions on other Apple platforms
- **Swift Version**: Requires Swift 6.0 or later with strict concurrency checking
