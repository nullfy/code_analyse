//
//  Medium_060_Permutation_Sequence.swift
//  algorithms
//
//  Created by 李晓东 on 2018/2/2.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

/*
 #60 Permutation Sequence
 
 Level: medium
 
 The set [1,2,3,…,n] contains a total of n! unique permutations.
 
 By listing and labeling all of the permutations in order,
 We get the following sequence (ie, for n = 3):
 
 "123"
 "132"
 "213"
 "231"
 "312"
 "321"
 Given n and k, return the kth permutation sequence.
 
 Note: Given n will be between 1 and 9 inclusive.
 
 Inspired by @lucastan at https://leetcode.com/discuss/11023/most-concise-c-solution-minimal-memory-required

 题解：
 做法：先把这n个数放入一个数组nums里，同时计算出n的阶乘fact。
 然后我们去建立第k个数，也就是java计数规则里的第k-1个数，所以先k--。
 怎么建立第k个数呢？这个数有n位数字，所以用0到n-1的for循环来做。
 这里应用了一个规律，确定第一个数，有n种选择，每种选择有(n-1)!种情况。选定第一个数之后，选择第二个数，有n-1种选择，每种选择有(n-2)!种情况。选定了前两个数，选择第三个数，有n-2种选择，每种选择有(n-3)!种情况。这样，总共有n!个数，每层循环的样本减少为fact/(n-i)。
 所以我们找第k个数，可以先确定它的第一位，从前往后类推。
 怎么确定第1位？如上所说，有n种选择，也就是将所有情况分为n组，每种包含(n-1)!个成员。那么，第k个数除以(n-1)!就可以得到这个数在第几组。假设这一组是第m组，第一个数就是nums.get(m)，同时删去这个数，并让k除以(n-1)!取余作为新的k。
 之后，把这个数从nums里删去，这样剩余n-1个数的相对位置不变，然后在这一组里找新的第k个数。如此循环，这样，下一组的成员数减少了，要找的位置k也更为精确了。
 */
struct Medium_060_Permutation_Sequence {
    static func getPermutation(n: Int, k arg: Int) -> String {
        var k = arg
        var j: Int
        var f: Int = 1
        var s = [Character](repeating: "0", count: n)
        let map: [Int: Character] = [
            1 : "1",
            2 : "2",
            3 : "3",
            4 : "4",
            5 : "5",
            6 : "6",
            7 : "7",
            8 : "8",
            9 : "9",
        ]
        for i in 1...n {
            f *= i
            s[i-1] = map[i]!
        }
        k -= 1
        for i in 0..<n {
            f /= n - i
            j = i + k/f
            let c = s[j]
            if j > i {
                for m in (i+1...j).reversed() {
                    s[m] = s[m-1]
                }
            }
            k %= f
            s[i] = c
        }
        return String(s)
    }
}
