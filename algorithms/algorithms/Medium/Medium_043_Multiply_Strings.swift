//
//  Medium_043_Multiply_Strings.swift
//  algorithms
//
//  Created by 李晓东 on 2017/12/27.
//  Copyright © 2017年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/multiply-strings/
 
 #43 Multiply Strings
 
 Level: medium
 
 Given two numbers represented as strings, return multiplication of the numbers as a string.
 
 Note: The numbers can be arbitrarily large and are non-negative.
 
 Inspired by @ChiangKaiShrek at https://leetcode.com/discuss/26602/brief-c-solution-using-only-strings-and-without-reversal
 题解：这道题让我们求两个字符串数字的相乘，输入的两个数和返回的数都是以字符串格式储存的，这样做的原因可能是这样可以计算超大数相乘，可以不受int或long的数值范围的约束，那么我们该如何来计算乘法呢，我们小时候都学过多位数的乘法过程，都是每位相乘然后错位相加，那么这里就是用到这种方法，参见网友JustDoIt的博客，把错位相加后的结果保存到一个一维数组中，然后分别每位上算进位，最后每个数字都变成一位，然后要做的是去除掉首位0，最后把每位上的数字按顺序保存到结果中即可
 */

import Foundation

private extension String {
    subscript(index: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: index)]
    }
}

struct Medium_043_Multiply_Strings {
    static func multiply(num1: String, num2: String) -> String {
        var sum = Array<Character>(repeating: "0", count: num1.characters.count+num2.characters.count) //放满都是0 的数组，一共有num1 num2 字数长度之和个元素
        
        let numDic: [Character : Int] = [
            "0": 0,
            "1": 1,
            "2": 2,
            "3": 3,
            "4": 4,
            "5": 5,
            "6": 6,
            "7": 7,
            "8": 8,
            "9": 9,
        ]
        for i in (0..<num1.characters.count-1).reversed() {
            var carry = 0
            for j in (0...num2.characters.count-1).reversed() {
                let tmp: Int = numDic[sum[i + j + 1]]! + numDic[num1[i]]! * numDic[num2[j]]! + carry
                sum[i + j + 1] = Character("\(tmp % 10 )")
                carry = tmp / 10
            }
            sum[i] = Character("\(numDic[sum[i]]! + carry)")
        }
        for i in (0 ... sum.count - 1).reversed() {
            if sum[i] != "0" {
                return String(sum[0...i])
            }
        }
        return "0"
    }
}
