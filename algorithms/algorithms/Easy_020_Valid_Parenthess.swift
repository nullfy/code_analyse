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
