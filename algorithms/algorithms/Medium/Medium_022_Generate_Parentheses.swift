//
//  Medium_022_Generate_Parentheses.swift
//  algorithms
//
//  Created by 李晓东 on 2017/12/2.
//  Copyright © 2017年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/generate-parentheses/
 
 #22 Generate Parentheses
 
 Level: medium
 
 Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.
 
 For example, given n = 3, a solution set is:
 
 "((()))", "(()())", "(())()", "()(())", "()()()"
 
 Inspired by @klyc0k at https://leetcode.com/discuss/14436/concise-recursive-c-solution

 题解：给定一个非负整数n，生成n 对括号的所有合法排列
 1、使用二叉树的方法
 
 */

struct Medium_022_Generate_Parentheses {
    static func help(arr: inout [String], str: String, n: Int, m: Int) {
        if m == 0 && n == 0 {
            arr.append(str)
            return
        }
        if m > 0 {
            help(arr: &arr, str: str + ")", n: n, m: m-1)
        }
        if n > 0 {
            help(arr: &arr, str: str + "(", n: n-1, m: m+1)
        }
        print(arr)
    }
    static func generateParenthesis(_ n: Int) -> [String] {
        var arr: [String] = []
        help(arr: &arr, str: "", n: n, m: 0)
        return arr
    }
}











