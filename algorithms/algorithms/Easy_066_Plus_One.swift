//
//  Easy_066_Plus_One.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/23.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/plus-one/
 
 #66 Plus One
 
 Level: easy
 
 Given a non-negative number represented as an array of digits, plus one to the number.
 
 The digits are stored such that the most significant digit is at the head of the list.
 
 Inspired by @zezedi at https://leetcode.com/discuss/14616/is-it-a-simple-code-c
 题解：将一个正整数逐位放进一个数组，完成加一的操作并返回
【0， 9】  ------->  【1， 0】
【9， 9】  ------->  【1， 0， 0】
 1、将数组从高位遍历，如果不为9 就将该元素加1然后返回
 2、如果最后位为9，将该元素赋值为0，
 需要注意的就是99的时候首尾要进位加一
 */
class Easy_066_Plus_One: NSObject {
    class func plusOne (_ digits: inout [Int]) -> [Int]{
        let n = digits.count
        for i in (0...n-1).reversed() {
            if digits[i] == 9 {
                digits[i] = 0
            } else {
                digits[i] += 1
                return digits
            }
        }
        if digits.first == 0 {
            digits.insert(1, at: 0)
        }
        return digits
    }
}
