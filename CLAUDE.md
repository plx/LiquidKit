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
- **Filter.swift**: Protocol and implementations for all Liquid filters
- **Tag.swift**: Base class and implementations for all Liquid tags
- **Operator.swift**: Comparison and logical operators (==, !=, >, <, contains, etc.)

## Current State

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

The project has good test coverage with tests for:
- All standard filters
- All standard tags
- Parser edge cases
- Operator behavior

When modernizing, ensure:
1. All existing tests pass
2. Add tests for any new Swift 6 features
3. Test on minimum deployment targets
4. Benchmark performance improvements

## Quick Start Commands

```bash
# Build the project
swift build

# Run tests
swift test

# Use in Xcode
open Package.swift
```

## Project Structure

```
LiquidKit/
├── Package.swift              # SPM manifest
├── Sources/
│   └── LiquidKit/
│       ├── Lexer.swift       # Template tokenization
│       ├── Parser.swift      # Token parsing and compilation  
│       ├── Filter.swift      # All filter implementations + strftime formatter
│       ├── Tag.swift         # All tag implementations
│       ├── Token.swift       # Value type system
│       ├── Context.swift     # Variable storage and scope
│       ├── Operator.swift    # Comparison and logical operators
│       ├── Error.swift       # Error types
│       └── Extensions/       # String and Double extensions
├── Tests/
│   └── LiquidKitTests/      # Comprehensive test suite
└── previous/                 # Original CocoaPods structure (reference only)

## Known Issues and Limitations

1. **Documentation**: Could benefit from more inline documentation and usage examples
2. **Performance**: Some recursive parsing patterns could potentially be optimized
3. **Advanced Liquid Features**: Some less common Liquid features may not be implemented

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

- **Thread Safety**: `Token`, `Lexer`, and filter/operator types are thread-safe. `Context` and `Parser` should be used on a single thread.
- **Migration Path**: Projects using the old CocoaPods version can migrate by updating imports and switching to SPM
- **Platform Requirements**: Requires iOS 13.0+, macOS 10.15+, or equivalent versions on other Apple platforms
- **Swift Version**: Requires Swift 6.0 or later with strict concurrency checking
