//
//  Medium_077_Combinations.swift
//  algorithms
//
//  Created by 李晓东 on 2018/4/2.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/combinations/
 
 #77 Combinations
 
 Level: medium
 
 Given two integers n and k, return all possible combinations of k numbers out of 1 ... n.
 
 For example,
 If n = 4 and k = 2, a solution is:
 
 [
 [2,4],
 [3,4],
 [2,3],
 [1,2],
 [1,3],
 [1,4],
 ]
 
 Inspired by @reeclapple at https://leetcode.com/discuss/5913/whats-the-best-solution and @nangao at https://leetcode.com/discuss/12915/my-shortest-c-solution-using-dfs
 题解： 给定两个整数 n 和 k 返回所有 k 个元素的数组，且数组中元素的范围在1-n 之间
 
 
 */
import Foundation


struct Medium_077_Combinations {
    static func combine(n: Int, k: Int) -> [[Int]] {
        var queue: [[Int]] = []         //最终结果的二维数组
        var summary: [[Int]] = []
        
        //首先将单独含有 1 - n 之间的元素包在一个数组中，
        for i in 1..<n {
            var list: [Int] = []
            list.append(i)
            queue.append(list)
        }
        /*
         以 n = 3, k = 2为例
         queue = [[1], [2]]
         */
        while queue.isEmpty == false {
            let list = queue.removeFirst()
            if list.count == k {
                summary.append(list)
            } else {
                if list.last! + 1 <= n {
                    for i in (list.last! + 1)...n {
                        var nextList: [Int] = [Int](list)
                        nextList.append(i)
                        queue.append(nextList)
                    }
                }
            }
        }
        
        return summary
    }
}
