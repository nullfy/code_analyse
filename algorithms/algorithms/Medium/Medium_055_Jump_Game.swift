//
//  Medium_055_Jump_Game.swift
//  algorithms
//
//  Created by 李晓东 on 2018/1/10.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/jump-game/
 
 #55 Jump Game
 
 Level: medium
 
 Given an array of non-negative integers, you are initially positioned at the first index of the array.
 
 Each element in the array represents your maximum jump length at that position.
 
 Determine if you are able to reach the last index.
 
 For example:
 A = [2,3,1,1,4], return true.
 
 A = [3,2,1,0,4], return false.
 题解：给定一个非负数数组，从第一个元素开始，元素的值表示能够往后跳的最大距离，问这样一个数组能否跳到最后一个元素。
 1.贪婪算法--从问题的某一个初始解出发一步一步进行，根据某个优化测度，每一步都要确保能够获得局部最优解
 */
import Foundation

struct Medium_055_Jump_Game {
    static func canJump(_ nums: [Int]) -> Bool {
        if nums.count == 0 {return false}
        var curr = nums[0]
        for i in 1..<nums.count {
            if curr == 0 {
                return false
            }
            curr = max(curr-1, nums[i])
            print("i--\(i)--",curr)
        }
        return true
    }
}
