//
//  Easy_058_Length_Of_Last_Word.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/21.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/length-of-last-word/
 
 #58 Length of Last Word
 
 Level: easy
 
 Given a string s consists of upper/lower-case alphabets and empty space characters ' ', return the length of last word in the string.
 
 If the last word does not exist, return 0.
 
 Note: A word is defined as a character sequence consists of non-space characters only.
 
 For example,
 Given s = "Hello World",
 return 5.
 
 Inspired by @eaglesky1990 at https://leetcode.com/discuss/9148/my-simple-solution-in-c
 题解：取到一段文字的最后一个单词的长度
 1、去掉字符串首尾的空格
 2、遍历字符串，引用一个tag标记，初值为0
 3、遇到空格tag就置为0，否则自增
 
 */

private extension String {
    subscript (index: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: index)]
    }
}

class Easy_058_Length_Of_Last_Word: NSObject {
    static func lengthOfLastWord(_ s: String) -> Int {
        var len = 0
        var i = 0
        while i < s.characters.count {
            if s[i] != " " {
                len += 1
            } else if i + 1 < s.characters.count && s[i+1] != " " {
                len = 0
            }
            i += 1
        }
        return len
    }
}
