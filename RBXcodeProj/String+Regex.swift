//
//  String+Regex.swift
//  RBXcodeProj
//
//  Created by rick on 23/03/15.
//  Copyright (c) 2015 ricobeck. All rights reserved.
//

import Foundation


extension String {
    
    func performRegex(pattern: String) -> [String: String]? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(rawValue: 0))
            let all = NSRange(location: 0, length: self.characters.count)
            var matches = [String: String]()
            
            regex.enumerateMatchesInString(self, options: [], range: all, usingBlock: { (result, _, _) -> Void in
                
                guard let result = result where result.numberOfRanges == 3 else { return }
                
                if let keyRange = result.rangeAtIndex(1).toRange() {
                    if let key = self.substringWithRange(keyRange) {
                        if let valueRange = result.rangeAtIndex(2).toRange() {
                            if let value = self.substringWithRange(valueRange) {
                                matches[key] = value
                            }
                        }
                    }
                }
            })
            if matches.count == 0 {
                return nil
            }
            else {
                return matches
            }
        } catch {
            
        }
        return nil
    }
    
    func substringWithRange(range: Range<Int>) -> String? {
        if range.startIndex < 0 || range.endIndex > self.characters.count {
            return nil
        }
        let range = Range(start: startIndex.advancedBy(range.startIndex), end: startIndex.advancedBy(range.endIndex))
        return self[range]
    }
}