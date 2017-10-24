//
//  Medium_003_Longest_SubString_Without_Repeating_Characters.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/11.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://oj.leetcode.com/problems/longest-substring-without-repeating-characters/
 
 #3 Longest Substring Without Repeating Characters
 
 Level: medium
 
 Given a string, find the length of the longest substring without repeating characters. For example, the longest substring without repeating letters for "abcabcbb" is "abc", which the length is 3. For "bbbbb" the longest substring is "b", with the length of 1.
 
 Inspired by @heiyanbin at https://oj.leetcode.com/discuss/6168/my-o-n-solution
 
 */
private extension String {
    func randomAccessCharactersArray() -> [Character] {
        return Array(self.characters)
    }
}

class Medium_003_Longest_SubString_Without_Repeating_Characters: NSObject {
    static func longest(_ s: String) -> Int {
        let charArr = s.randomAccessCharactersArray()
        let len = charArr.count
        if len <= 1 {
            return len
        } else {
            var tmpMaxLen = 1
            var maxLen = 1
            var hashMap = Dictionary<Character, Int>()
            hashMap[charArr[0]] = 0
            for i in 1..<len {
                if let lastPosition = hashMap[charArr[i]] {
                    if lastPosition < i - tmpMaxLen {
                        tmpMaxLen += 1
                    } else {
                        tmpMaxLen = i - lastPosition
                    }
                } else {
                    tmpMaxLen += 1
                }
                hashMap[charArr[i]] = i
                if tmpMaxLen > maxLen {
                    maxLen = tmpMaxLen
                }
            }
            return maxLen
        }
    }
}
