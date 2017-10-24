//
//  Medium_005_Longest_Palindromic_Substring.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/11.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://oj.leetcode.com/problems/longest-palindromic-substring/
 
 #5 Longest Palindromic Substring
 
 Level: medium
 
 Given a string S, find the longest palindromic substring in S. You may assume that the maximum length of S is 1000, and there exists one unique longest palindromic substring.
 
 Inspired by @hh1985 at https://leetcode.com/discuss/32204/simple-c-solution-8ms-13-lines
 
 */

private extension String {
    subscript (range: Range<Int>) -> String {
        let start = self.characters.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.characters.index(self.startIndex, offsetBy: range.upperBound, limitedBy: self.endIndex)
        return self[start..<end!]
    }
    
    func randomAccessCharactersArray() -> [Character] {
        return Array(self.characters)
    }
}
class Medium_005_Longest_Palindromic_Substring: NSObject {
    static func longestPalindrome(_ s: String) ->String {
        guard s.characters.count > 1 else {
            return s
        }
        
        var startIndex: Int = 0
        var maxLen: Int = 1
        var i = 0
        let charArr = s.randomAccessCharactersArray()
        while i < s.characters.count {
            guard s.characters.count - i  > maxLen/2 else {
                break
            }
            var j = i
            var k = i
            while k < s.characters.count - 1 && charArr[k+1] == charArr[k] {
                k += 1
            }
            i = k + 1
            while  k < s.characters.count - 1 && j > 0 && charArr[k+1] == charArr[j-1] {
                k += 1
                j -= 1
            }
            let newLen = k - j + 1
            if newLen > maxLen {
                startIndex = j
                maxLen = newLen
            }
        }
        return String(charArr[startIndex..<(startIndex+maxLen)])
    }
}
