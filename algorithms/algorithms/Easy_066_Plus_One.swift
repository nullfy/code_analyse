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
        digits[0] = 1
        digits.append(0)
        return digits
    }
}
