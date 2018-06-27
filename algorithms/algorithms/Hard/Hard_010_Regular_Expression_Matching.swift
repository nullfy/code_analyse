//
//  Hard_010_Regular_Expression_Matching.swift
//  algorithms
//
//  Created by null on 2018/6/27.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://oj.leetcode.com/problems/regular-expression-matching/
 
 #10 Regular Expression Matching
 
 Level: hard
 
 Implement regular expression matching with support for '.' and '*'.
 
 '.' Matches any single character.
 '*' Matches zero or more of the preceding element.
 
 The matching should cover the entire input string (not partial).
 
 The function prototype should be:
 bool isMatch(const char *s, const char *p)
 
 Some examples:
 isMatch("aa","a") → false
 isMatch("aa","aa") → true
 isMatch("aaa","aa") → false
 isMatch("aa", "a*") → true
 isMatch("aa", ".*") → true
 isMatch("ab", ".*") → true
 isMatch("aab", "c*a*b") → true
 
 Inspired by @xiaohui7 at https://leetcode.com/discuss/18970/concise-recursive-and-dp-solutions-with-full-explanation-in
 题解：通过传入的两个字符来判断是否匹配，其中 "."匹配任何单个字母, "*"匹配0个或多个前面的元素
 */

import Foundation

private extension String {
    subscript (index: Int ) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: index)]
    }
    
    subscript (range: Range<Int>) -> String {
        return String(self[self.characters.index(self.startIndex, offsetBy: range.lowerBound) ..< self.characters.index(self.startIndex, offsetBy: range.upperBound)])
    }
}

class Hard_010_Regular_Expression_Matching {
    class func isMatch_recursion(s: String, p: String) -> Bool {
        //递归的解法
        if p.characters.count == 0 {
            return s.characters.count == 0
        }
        if p.characters.count > 1 && p[1] == "*" {
            return isMatch_recursion(s:s, p: p[2..<p.characters.count]) || s.characters.count != 0 && (s[0] == p[0] || p[0] == ".") && isMatch_recursion(s: s[1..<s.characters.count], p: p)
        } else {
            return s.characters.count != 0 && (s[0] == p[0] || p[0] == ".") && isMatch_recursion(s: s[1..<s.characters.count], p: p[1 ..< p.characters.count])
        }
    }
}
