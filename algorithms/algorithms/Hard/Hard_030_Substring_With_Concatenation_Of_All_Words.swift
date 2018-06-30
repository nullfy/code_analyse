//
//  Hard_030_Substring_With_Concatenation_Of_All_Words.swift
//  algorithms
//
//  Created by null on 2018/6/30.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/substring-with-concatenation-of-all-words/
 
 #30 Substring with Concatenation of All Words
 
 Level: hard
 
 You are given a string, s, and a list of words, words, that are all of the same length. Find all starting indices of substring(s) in s that is a concatenation of each word in words exactly once and without any intervening characters.
 
 For example, given:
 s: "barfoothefoobarman"
 words: ["foo", "bar"]
 
 You should return the indices: [0,9].
 (order does not matter).
 
 Inspired by @ramakanthd92 at https://leetcode.com/discuss/366/better-solution-than-brute-force
 题解：给定一串字符串，同时给定一组单词数组，在这串字符串中找到单词的下标，同时返回下标的值
 */

import Foundation

private extension String {
    subscript(range: Range<Int>) -> String {
        guard let localEndIndex = self.characters.index(self.startIndex, offsetBy: range.upperBound,  limitedBy: self.endIndex)  else {
            return String(self[self.characters.index(self.startIndex, offsetBy: range.lowerBound)..<self.endIndex])
        }
        return String(self[self.characters.index(self.startIndex, offsetBy: range.lowerBound)..<localEndIndex])
    }
}

class Hard_030_Substring_With_Concatenation_Of_All_Words {
    class func findSubstring(s: String?, words: [String]) -> [Int] {
        if s == nil || words.count == 0 {
            return []
        }
        var result: [Int] = []
        var dic1: [String: Int] = [String: Int]()
        var dic2: [String: Int] = [String: Int]() //两个string：int的字典
        let stringLength: Int = (s!).characters.count//要匹配字符的长度
        let wordListSize: Int = words.count //字符数组的长度
        let wordLength: Int = words[0].characters.count //字符数组首个字符的长度
        
        //这一步是用dic 记录字符数组中每个元素出现的次数 并用 字符：次数 来对应
        for i in 0..<wordListSize {
            if dic1[words[i]] == nil {
                dic1[words[i]] = 1
            } else {
                dic1[words[i]]! += 1
            }
        }
        
        var s1: String
        var s2: String
        var counter1: Int
        var counter2: Int
        
        for i in 0..<wordLength {
            counter1 = 0
            counter2 = i
            var j = i
            while j < stringLength {
                s1 = s![j..<j+wordLength]
                if dic1[s1] == nil {
                    dic2.removeAll(keepingCapacity: false)
                    counter1 = 0
                    counter2 = j + wordLength
                } else if dic2[s1] == nil || dic2[s1]! < dic1[s1]! {
                    if dic2[s1] == nil {
                        dic2[s1] = 1
                    } else {
                        dic2[s1]! += 1
                    }
                    counter1 += 1
                } else {
                    s2 = s![counter2 ..< counter2+wordLength]
                    while s2 != s1 {
                        dic2[s2]! -= 1
                        counter1 -= 1
                        counter2 += wordLength
                        s2 = s![counter2..<counter2+wordLength]
                    }
                    counter2 += wordLength
                }
                if counter1 == wordListSize {
                    result.append(counter2)
                    s2 = s![counter2..<counter2+wordLength]
                    dic2[s2]! -= 1
                    counter1 -= 1
                    counter2 += wordLength
                }
                j += wordLength
            }
            dic2.removeAll(keepingCapacity: false)
        }
        return result
    }
}
