//
//  Easy_028_Implement_Str.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/18.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

/*
 
 https://leetcode.com/problems/implement-strstr/
 
 #28 Implement strStr()
 
 Implement strStr().
 
 Returns the index of the first occurrence of needle in haystack, or -1 if needle is not part of haystack.
 
 Brute-force inspired by @shichaotan at https://leetcode.com/discuss/19962/a-very-clean-solution-brute-force
 
 KMP inspired by @zhenhai at https://leetcode.com/discuss/11814/accepted-kmp-solution-in-java-for-reference
 
 题解：实现字符串匹配，返回匹配的第一个索引，如果没有匹配就返回-1
 1.
 */

private extension String {
    subscript (index: Int) -> Character {
        //subscript 自定义下标，
        return self[self.characters.index(self.startIndex, offsetBy: index)]
    }
}

class Easy_028_Implement_Str: NSObject {
    class func strStr_brute_force(hayStack: String?, needle: String?) -> Int {
        if hayStack == nil || needle == nil {
            return -1
        }
        
        var i = 0 , j = 0
        while true {
            while true {
                if j >= (needle!).characters.count {
                    return i
                }
                if i + j >= (hayStack!).characters.count{
                    return -1
                }
                if hayStack![i+j] != needle![j] {
                    break
                }
                j += 1
            }
            i += 1
            print("i--\(i), j---\(j)")
        }
    }
    
    class func strStr_KMP(hayStack: String?, needle: String?) -> Int {
        if hayStack == nil || needle == nil {
            return -1
        }
        
        if needle!.characters.count == 0 {
            return 0
        }
        
        if hayStack?.characters.count == 0 {
            return -1
        }
        var arr: [Character] = Array((needle!).characters)
        var next: [Int] = makeNext(arr)
        var i = 0
        var j = 0
        let end = hayStack!.characters.count //这里如果不强制解包，下面的while也要强制
        while  i < end {
            if j == -1 || hayStack![i] == arr[j] {
                j += 1
                i += 1
                if j == arr.count {
                    return i - arr.count
                }
            }
            if i < end && hayStack![i] != arr[j] {
                j = next[j]
            }
        }
        return -1
    }
    
    class func makeNext(_ arr: [Character]) -> [Int] {
        var next: [Int] = [Int](repeating: -1, count: arr.count)
        var i = 0
        var j = -1
        
        while i + 1 < arr.count {
            if j == -1 || arr[i] == arr[j] {
                next[i + 1] = j + 1
                if arr[i+1] == arr[j+1] {
                    next[i+1] = next[j+1]
                }
                j += 1
                i += 1
            }
            if arr[i] != arr[j] {
                j = next[j]
            }
        }
        return next
    }
}
