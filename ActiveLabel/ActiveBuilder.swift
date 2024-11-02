//
//  ActiveBuilder.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = ((String) -> Bool)

struct ActiveBuilder {
    
    static func createElements(type: ActiveType, from text: String, range: NSRange, filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag:
            return createElementsIgnoringFirstCharacter(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .url:
            return createElements(from: text, for: type, range: range, filterPredicate: filterPredicate)
        case .custom:
            return createElements(from: text, for: type, range: range, minLength: 1, filterPredicate: filterPredicate)
        }
    }
    
    static func createURLElements(from text: String, range: NSRange, maximumLength: Int?) -> ([ElementTuple], String) {
        let type = ActiveType.url
        var text = text
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return ([], text)
        }
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        var elements: [ElementTuple] = []
        var offset = 0

        for match in matches where match.range.length > 2 {
            // Adjust the range to account for previous replacements
            let adjustedRange = NSRange(location: match.range.location + offset, length: match.range.length)
            guard let matchRange = Range(adjustedRange, in: text) else { continue }
            let word = String(text[matchRange])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let trimmedWord: String
            if let maxLength = maximumLength, word.count > maxLength {
                trimmedWord = word.trim(to: maxLength)
            } else {
                trimmedWord = word
            }

            // Replace the word in the text at the specific range
            text.replaceSubrange(matchRange, with: trimmedWord)

            // Calculate new range for the trimmed word (including the ellipsis)
            let lengthDifference = trimmedWord.count - word.count
            let newRangeLocation = adjustedRange.location
            let newRangeLength = trimmedWord.count
            let newRange = NSRange(location: newRangeLocation, length: newRangeLength)
            
            // Update offset for subsequent replacements
            offset += lengthDifference

            let element = ActiveElement.url(original: word, trimmed: trimmedWord)
            elements.append((newRange, element, type))
        }
        return (elements, text)
    }
    
    private static func createElements(from text: String,
                                       for type: ActiveType,
                                       range: NSRange,
                                       minLength: Int = 2,
                                       filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > minLength {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if filterPredicate?(word) ?? true {
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
    
    private static func createElementsIgnoringFirstCharacter(from text: String,
                                                             for type: ActiveType,
                                                             range: NSRange,
                                                             filterPredicate: ActiveFilterPredicate?) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        var elements: [ElementTuple] = []

        for match in matches where match.range.length > 1 {
            guard let matchRange = Range(match.range, in: text) else { continue }
            // Skip the first character
            let wordStartIndex = text.index(after: matchRange.lowerBound)
            let wordRange = wordStartIndex..<matchRange.upperBound
            var word = String(text[wordRange])

            // Remove additional "@" or "#" if present
            if word.hasPrefix("@") || word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }

            if filterPredicate?(word) ?? true {
                // Store the original match range to highlight the entire mention
                let element = ActiveElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
}
