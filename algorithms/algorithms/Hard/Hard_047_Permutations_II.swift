//
//  Hard_047_Permutations_II.swift
//  algorithms
//
//  Created by null on 2018/7/12.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/permutations-ii/
 
 #47 Permutations II
 
 Level: hard
 
 Given a collection of numbers that might contain duplicates, return all possible unique permutations.
 
 For example,
 [1,1,2] have the following unique permutations:
 [1,1,2], [1,2,1], and [2,1,1].
 
 Inspired by @TransMatrix at https://leetcode.com/discuss/10609/a-non-recursive-c-implementation-with-o-1-space-cost
 
 */

import Foundation

struct Hard_047_Permutations_II {
    private static func reverseInPlace(nums: inout [Int], begin bgn: Int, end ed: Int) {
        var begin = bgn
        var end = ed
        while begin < end {
            nums.swapAt(begin, end)
            begin += 1
            end -= 1
        }
    }
    
    static func permuteUnique(_ n: [Int]) -> [[Int]] {
        var num = n
        var result = [[Int]]()
        num.sort{$0 < $1}
        result.append(num)
        while true {
            var i: Int = num.count - 1
            for _ in (1..<num.count).reversed() {
                if num[i-1] < num[i] {
                    break;
                }
                i -= 1
            }
            
            if i == 0 {
                break
            }
            
            var j: Int = num.count - 1
            for _ in (i..<num.count).reversed() {
                if num[j] > num[i - 1] {
                    break
                }
                j -= 1
            }
            num.swapAt(i-1, j)
            reverseInPlace(nums: &num, begin: i, end: num.count - 1)
            result.append(num)
        }
        return result
    }
}
