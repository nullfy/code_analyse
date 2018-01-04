//
//  Medium_049_Anagrams.swift
//  algorithms
//
//  Created by 李晓东 on 2018/1/4.
//  Copyright © 2018年 XD. All rights reserved.
//


/*
 
 https://leetcode.com/problems/anagrams/
 
 #49 Anagrams
 
 Level: medium
 
 Given an array of strings, group anagrams together.
 
 For example, given: ["eat", "tea", "tan", "ate", "nat", "bat"],
 Return:
 
 [
 ["ate", "eat","tea"],
 ["nat","tan"],
 ["bat"]
 ]
 
 Note: All inputs will be in lower-case.
 
 Inspired by @zxyperfect at https://leetcode.com/discuss/18664/sharing-my-very-concise-solution-with-explanation
 题解：给定一个英语单词为基本单位的数组，找到含有相同字母的字符串，不管单词中字母的顺序，
 1.给每个单词进行排序
 2.利用dict 以排好序的字符串为key， 以不同排列的字符串组成的数组为value
 3.遍历给定的数组，先对元素进行字母排序，然后再在dict 中查找是否有了这个key，没有就添加
 */
import Foundation

struct Medium_049_Anagrams {
    private static func helper(_ str: String) -> String {
        var arr = Array(str.characters)
        arr.sort()
        return String(arr)
    }
    
    static func anagrams(_ strings: [String]) -> [[String]] {
        var dict: [String: [String]] = [: ]
        for s in strings {
            let sortedS = helper(s)
            var arr = dict[sortedS]
            if let _ = arr {
                arr!.append(s)
            } else {
                arr = [s]
            }
            dict[sortedS] = arr!
        }
        return Array(dict.values)
    }
}




