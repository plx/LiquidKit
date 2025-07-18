//
//  NSRegularExpression+Additions.swift
//  LiquidKit
//
//  Created by Bruno Philipe on 7/10/18.
//

import Foundation

extension NSRegularExpression
{
	/// Regex pattern to match range expressions like "(1..10)"
	static let rangeRegex: NSRegularExpression = {
		do {
			return try NSRegularExpression(pattern: "\\(([^\\.\\n]+)\\.\\.([^\\.\\n]+)\\)", options: [])
		} catch {
			// This pattern is hardcoded and should never fail
			fatalError("Failed to compile range regex pattern: \(error)")
		}
	}()
}
