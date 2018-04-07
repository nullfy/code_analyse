//
//  Medium_078_Subsets.swift
//  algorithms
//
//  Created by 李晓东 on 2018/4/3.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/subsets/
 
 #78 Subsets
 
 Level: medium
 
 Given a set of distinct integers, nums, return all possible subsets.
 
 Note:
 Elements in a subset must be in non-descending order.
 The solution set must not contain duplicate subsets.
 For example,
 If nums = [1,2,3], a solution is:
 
 [
 [3],
 [1],
 [2],
 [1,2,3],
 [1,3],
 [2,3],
 [1,2],
 []
 ]
 
 Inspired by @thumike at https://leetcode.com/discuss/9213/my-solution-using-bit-manipulation
 
 题解：给定一个数组，返回所有可能的排列组合，
 比如[1,2,3] 会返回
 [
 [3],
 [1],
 [2],
 [1,2,3],
 [1,3],
 [2,3],
 [1,2],
 []
 ]
 
 */


import Foundation

struct Medium_078_Subsets {
    static func subsets(_ n: [Int]) -> [[Int]] {
        //这种解法速度比较慢
        var nums = n
        nums.sort {$0 > $1}
        let elmNum = nums.count
        let subsetNum = Int(pow(2.0, Double(elmNum)))
        
        var subsets: [[Int]] = [[Int]](repeatElement([], count: subsetNum))
        for i in 0..<elmNum {
            for j in 0..<subsetNum {
                if (j >> i & 1) != 0 {
                    subsets[j].append(nums[i])
                }
            }
        }
        return subsets
    }
    
    static func subsets_II(_ nums: [Int]) -> [[Int]] {
        var ret: [[Int]] = []
        
        //首先将nums
        for n in nums {
            var nextRet = ret
            
            for r in ret {
                nextRet.append(r + [n]) //这里是数组之间的组合比如说[1] + [1] ==> [1, 1]
            }
            
            nextRet.append([n])
            ret = nextRet
            /**
             以[1,3,2] 为例 ret 再每一轮循环后的值
             1、[1]
             2、[[1],[1,3],[3]]
             3、[[1],[1,3],[3],[1,2],[1,3,2],[3,2],[2]] 其实这里还是在最初的时候加个排序最好
             **/
        }

        ret.append([])
        
        return ret
    }
}
