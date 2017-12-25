//
//  Medium_040_Combination_Sum_II.swift
//  algorithms
//
//  Created by 李晓东 on 2017/12/25.
//  Copyright © 2017年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/combination-sum-ii/
 
 #40 Combination Sum II
 
 Level: medium
 
 Given a collection of candidate numbers (C) and a target number (T), find all unique combinations in C where the candidate numbers sums to T.
 
 Each number in C may only be used once in the combination.
 
 Note:
 All numbers (including target) will be positive integers.
 Elements in a combination (a1, a2, … , ak) must be in non-descending order. (ie, a1 ≤ a2 ≤ … ≤ ak).
 The solution set must not contain duplicate combinations.
 For example, given candidate set 10,1,2,7,6,1,5 and target 8,
 A solution set is:
 [1, 7]
 [1, 2, 5]
 [2, 6]
 [1, 1, 6]
 
 Inspired by @dylan_yu at https://leetcode.com/discuss/10141/a-solution-avoid-using-set (the same works for both #39 and #40)
 题解：给定一个整型数组，同时给定一个值，求出数组中元素相加等于目标值的解法，
 
 */

struct Medium_040_Combination_Sum_II {
    private static func recurse(list: [Int], target: Int, candidates: [Int], index: Int, result: inout [[Int]]) {
        if target == 0 {
            result.append(list)
            return
        }
        
        var tmp = index - 1
        for i in index..<candidates.count {
            if i > tmp {
                let newTarget: Int = target - candidates[i]
                if newTarget > 0 {
                    var copy: [Int] = Array<Int>(list)
                    copy.append(candidates[i])
                    recurse(list: copy, target: newTarget, candidates: candidates, index: i+1, result: &result)
                    
                    tmp = i
                    while tmp+1 < candidates.count && candidates[tmp+1] == candidates[tmp] {
                        tmp += 1
                    }
                } else {
                    break
                }
            }
        }
    }
    
    static func combinationSum(candidates c: [Int], target: Int) -> [[Int]] {
        var candidates = c
        var result = [[Int]]()
        candidates.sort{$0 < $1} //递增排列
        recurse(list: [Int](), target: target, candidates: candidates, index: 0, result: &result)
        return result
    }
}
