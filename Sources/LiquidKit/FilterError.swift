import Foundation

public enum FilterError: Error, LocalizedError {
  
  /// Corresponds to errors wherein the `parameters` list is structurally valid, but one or more values are invalid (e.g. like passing `0` to a `divide_by` filter).
  case invalidArgument(String)
  
  /// Corresponds to errors wherein the `parameters` list is fundamentally wrong, like passing parameters to a parameterless filter.
  case improperParameters(String)
  
  public var errorDescription: String? {
    switch self {
    case .invalidArgument(let message):
      message
    case .improperParameters(let message):
      message
    }
  }
  
}

