//
//  Easy_027_Remove_Element.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/16.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/remove-element/
 
 #27 Remove Element
 
 Level: easy
 
 Given an array and a value, remove all instances of that value in place and return the new length.
 
 The order of elements can be changed. It doesn't matter what you leave beyond the new length.
 
 Inspired by @daxianji007 at https://leetcode.com/discuss/3753/my-solution-for-your-reference
 
 题解：移除指定数组中的指定元素，同时返回移除后数组元素的个数
 一层循环，同时引入一个index作为下标
 如果i元素元素不等于指定值，那么index随着i自增
 如果i元素等于指定值，break进入下一次循环
 在下一次循环中将i 赋值给 i-1，这样就覆盖了要移除的指定值
 */
class Easy_027_Remove_Element: NSObject {
    class func removeElemet(_ array: inout [Int], elem: Int) -> Int {
        var begin: Int = 0
        for i in 0 ..< array.count {
            if array[i] != elem {
                array[begin] = array[i]
                begin += 1
            }
        }
        return begin
    }
}
