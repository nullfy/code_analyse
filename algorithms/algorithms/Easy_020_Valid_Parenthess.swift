//
//  Easy_020_Valid_Parenthess.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/13.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

/*
 #19 Remove Nth Node From End of List
 
 Level: easy
 
 Given a linked list, remove the nth node from the end of list and return its head.
 
 For example,
 
 Given linked list: 1->2->3->4->5, and n = 2.
 
 After removing the second node from the end, the linked list becomes 1->2->3->5.
 
 Note:
 
 Given n will always be valid.
 Try to do this in one pass.
 
 Inspired by @i at https://leetcode.com/discuss/1656/is-there-a-solution-with-one-pass-and-o-1-space
 
 题解：验证有效括号
 栈法：验证一个有效的括号，有一个右括号必定有一个左括号在前面，所以我们可以将左括号和右括号利用Dictionary来对应好，
 1.遍历字符串，获得每一个字符
 2.
 */

private extension String {
    subscript (index: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: index)]
    }
}

class Easy_020_Valid_Parenthess: NSObject {
    class func isValid(_ s: String) -> Bool {
        var stack: [Character] = []
        var tmp: Character
        var dic: Dictionary<Character, Character> = Dictionary.init()
        dic["]"] = "["
        dic[")"] = "("
        dic["}"] = "{"
        for i in 0..<s.characters.count {
            tmp = s[i]
            if tmp == ")" || tmp == "}" || tmp == "]" {
                if stack.count == 0 || stack.last != dic[tmp] {
                    return false
                } else {
                    stack.removeLast()
                }
            } else {
                stack.append(tmp)
            }
        }
        if stack.count == 0 {
            return true
        } else {
            return false
        }
    }
}
