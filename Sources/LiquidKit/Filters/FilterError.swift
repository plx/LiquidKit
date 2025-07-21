import Foundation

public enum FilterError: Error, LocalizedError {
  
  case invalidArgument(String)
  
  public var errorDescription: String? {
    switch self {
    case .invalidArgument(let message):
      message
    }
  }
  
}

