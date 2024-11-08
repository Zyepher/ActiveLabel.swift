//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {
    static let hashtagPattern = "(?:^|\\s|$)#[\\p{L}0-9_]*"
    static let mentionPattern = "(?:^|\\s|$|[.])@[\\p{L}0-9_.]*"
    static let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +  // Leading boundary
        "((https?://|www\\.|pic\\.)" +  // Protocols and common prefixes
        "[\\p{L}\\p{N}\\-_.]+" +  // Domain with Unicode support
        "\\.[\\p{L}]{2,}" +  // TLD with Unicode support
        "(\\.[\\p{L}]{2,})?" +  // Optional secondary TLD
        "(:\\d{1,5})?" +  // Optional port
        "(/[\\p{L}\\p{N}\\-./_?%&=;@]*)?" +  // Path with extended symbols
        "(\\?[\\p{L}\\p{N}&=_%+-]*)?" +  // Optional query parameters
        "(#[\\p{L}\\p{N}\\-_]*)?)" +  // Optional fragment
        "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"  // Trailing boundary

    private static var cachedRegularExpressions: [String : NSRegularExpression] = [:]

    static func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }

    private static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }
}
