//
//  Easy_020_Valid_Parenthess.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/13.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

/*
 
 https://leetcode.com/problems/valid-parentheses/
 
 #20 Valid_Parentheses
 
 Level: easy
 
 Given a string containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.
 
 The brackets must close in the correct order, "()" and "()[]{}" are all valid but "(]" and "([)]" are not.
 
 Inspired by @exodia at https://leetcode.com/discuss/21440/sharing-my-simple-cpp-code-with-2ms
 


 题解：验证有效括号
 栈法：验证一个有效的括号，有一个右括号必定有一个左括号在前面，所以我们可以将左括号和右括号利用Dictionary来对应好，
 1.将每种括号的后面那个作为key，前面的括号作为value,建好 dic
 2.遍历所有字符，如果字符为后面那个括号 就判断栈中是否有值，且栈顶是不是一种前括号
 3.如果是前括号都进行压栈操作
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
