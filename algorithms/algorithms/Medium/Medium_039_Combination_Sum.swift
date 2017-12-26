//
//  Medium_039_Combination_Sum.swift
//  algorithms
//
//  Created by 李晓东 on 2017/12/23.
//  Copyright © 2017年 XD. All rights reserved.
//

import Foundation
/*
 
 https://leetcode.com/problems/combination-sum/
 
 #39 Combination Sum
 
 Level: medium
 
 Given a set of candidate numbers (C) and a target number (T), find all unique combinations in C where the candidate numbers sums to T.
 
 The same repeated number may be chosen from C unlimited number of times.
 
 Note:
 All numbers (including target) will be positive integers.
 Elements in a combination (a1, a2, … , ak) must be in non-descending order. (ie, a1 ≤ a2 ≤ … ≤ ak).
 The solution set must not contain duplicate combinations.
 For example, given candidate set 2,3,6,7 and target 7,
 A solution set is:
 [7]
 [2, 2, 3]
 
 Inspired by @dylan_yu at https://leetcode.com/discuss/10141/a-solution-avoid-using-set
 题解：给定一个整型数组，一个目标值。可以重复用其中的元素相加得到目标值，求解法有几种
 
 */

struct Medium_039_Combination_Sum {
    private static func recurse(list: [Int], target: Int, candidates: [Int], index: Int, result: inout [[Int]]) {
        if target == 0 {
            result.append(list)
            return
        }
        
        for i in index ..< candidates.count {
            let newTarget: Int = target - candidates[i]
            if newTarget >= 0 {
                var copy: [Int] = Array<Int>(list)
                copy.append(candidates[i])
                recurse(list: copy, target: newTarget, candidates: candidates, index: i, result: &result)
            } else {
                break
            }
        }
    }
    
    static func combinationSum(candidates cdts: [Int], target: Int) -> [[Int]] {
        var candidates = cdts
        var result: [[Int]] = []
        candidates.sort{$0 < $1}
        recurse(list: [Int](), target: target, candidates: candidates, index: 0, result: &result)
        return result
    }
}

