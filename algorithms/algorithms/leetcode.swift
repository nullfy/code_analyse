//
//  leetcode.swift
//  algorithms
//
//  Created by 李晓东 on 2017/6/10.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

class leetcode: NSObject {
    
    
    /*
     Given an array and a value, remove all instances of that > value in place and return the new length.
     The order of elements can be changed. It doesn't matter what you leave beyond the new length
     
     给定数组，移除数组内的目标值，并返回数组长度
     */
    public class func removeElment(array: inout [Int], n: Int, elem: Int) -> Int {
        /*
         eg
         [1,2,2,4,5] target=2
         
         step1:[1,2,2,4,5] i=0 j=0
         step2:[1,2,2,4,5] i=1 j=0
         step3:[1,2,2,4,5] i=2 j=0
         step4:[1,4,2,4,5] i=3 j=1
         step5:[1,4,5,4,5] i=4 j=2
         
         思路:
         1. 对给定数组进行循环，j 用于记录不重复值个数
         2. 元素i 与目标值相等时，循环继续走，不相等时 j自增，同时将此时i 元素的值赋给 j 元素上
         3. 移除超过 j 值的元素
         */
        var j = 0
        var i = 0
        while i < n {
            if array[i] != elem {
                array[j] = array[i]
                j+=1
            }
            i+=1
            print(array)
        }
        array.removeLast(n - j)
        print(array)
        return j
    }
    
    /*
     Given a sorted array, remove the duplicates in place such that > each element appear only once
     and return the new length.
     Do not allocate extra space for another array, you must do this in place with constant memory.
     For example, Given input array A = [1,1,2],
     Your function should return length = 2, and A is now [1,2].
     
     给定排序好的数组，移除重复项，只有一种重复值，返回去重后数组的个数
     ps:不能开辟新的空间
     
     思路：
     1.两个下标 i和j ，i 用于循环自增，j 用于记录非重复值的个数
     2.当 i元素与 j元素不相同时，j 自增，同时将 i元素赋值给 j元素
     
     步骤
     [1, 4, 4, 6, 7, 8] i-- 1 j-- 1
     [1, 4, 4, 6, 7, 8] i-- 2 j-- 1
     [1, 4, 6, 6, 7, 8] i-- 3 j-- 2
     [1, 4, 6, 7, 7, 8] i-- 4 j-- 3
     [1, 4, 6, 7, 8, 8] i-- 5 j-- 4
     */
    public class func removeDupliteFromSortedArray(array: inout [Int]) -> Int {
        if (array.count == 0) {
            return 0
        }
        var j = 0
        for i in 1...(array.count - 1) {
            if array[i] != array[j] {
                j+=1
                array[j] = array[i]
            }
            print(array,"i--",i,"j--",j)
        }
        array.removeLast(array.count-j-1)
        return j+1
    }
    
    /*
     Follow up for "Remove Duplicates": What if duplicates are allowed at most twice?
     For example, Given sorted array A = [1,1,1,2,2,3],
     Your function should return length = 5, and A is now [1,1,2,2,3].
     
     还是给定排序好的数组，移除重复项，不同的是有重复的次数不能超过2
     */
    
    public class func removeMultipDupliteFromSortedArray(array: inout [Int]) -> Int {
        if array.count == 0 {
            return 0
        }
        var num = 0
        var j = 0
        for i in 1...(array.count - 1) {
            if array[j] == array[i] {
                num += 1
                if num < 2 {
                    j += 1
                    array[j] = array[i]
                }
            } else {
                j+=1
                array[j] = array[i]
                num = 0
            }
            print(array)
        }
        array.removeLast(array.count-j-1)
        print(array)
        return j+1
    }
    
    /*
     Given a non-negative number represented as an array of digits, plus one to the number.
     The digits are stored such that the most significant digit is at the head of the list.
     
     这道题的意思是将数组看成一个数然后进行加一操作,需要考虑的就是尾数为9 要进位
     
     思路：
     对给定的数组进行逆序循环，然后逐个加1 ，为9则将该位置为0
     如果第一位为9，需要在首位插入1
     */
    
    public class func plusOne(array: inout [Int]) -> [Int]{
        let n = array.count
        if n == 0 {
            return [Int]()
        }
        for i in (0...n-1).reversed() {
            if array[i] < 9 {
                array[i] += 1
                return array
            }
            array[i] = 0
        }
        array.insert(1, at: 0)
        return array
    }
    
    /*
     Given numRows, generate the first numRows of Pascal's triangle.
     For example, given numRows = 5, Return
     
     [
     [1]
     [1, 1]
     [1, 2, 1]
     [1, 3, 3, 1]
     [1, 4, 6, 4, 1]
     [1, 5, 10, 10, 5, 1]
     [1, 6, 15, 20, 15, 6, 1]
     [1, 7, 21, 35, 35, 21, 7, 1]
     ]
     要得到一个帕斯卡三角，我们只需要找到规律即可。
     第k层有k个元素
     每层第一个以及最后一个元素值为1
     对于第k（k > 2）层第n（n > 1 && n < k）个元素A[k][n]，A[k][n] = A[k-1][n-1] + A[k-1][n]
     
     
     */
    public class func generatePascaltriangle(row: Int) -> [[Int]] {
        if row <= 0 {
            return [[Int]]()
        }
        var array = [[Int]]()
        for i in 1...row {
            var sub = [Int]()
            for j in 0...i-1 {
                if j == 0 || (j > 0 && j == i-1){
                    sub.append(1)
                } else {
                    let before = array[i-2]
                    sub.append(before[j]+before[j-1])
                    //print("i--",i,"j---j",before)
                }
            }
            array.append(sub)
            print(sub)
        }
        return array
    }
    
    
    /*
     Given an index k, return the kth row of the Pascal's triangle.
     For example, given k = 3, Return [1,3,3,1].
     
     帕斯卡三角II 与上面不同的是不需要返回从1到n的所有数组，只要n对应的数组
     */
    
    public class func generatePascalTriangleII(_ row: Int) -> [Int] {
        if row <= 0 {
            return [[Int]]()
        }
        var array = [[Int]]()
        for i in 1...row {
            var sub = [Int]()
            for j in 0...i-1 {
                if j == 0 || (j > 0 && j == i-1){
                    sub.append(1)
                } else {
                    let before = array[i-2]
                    sub.append(before[j]+before[j-1])
                    //print("i--",i,"j---j",before)
                }
            }
            array.append(sub)
            print(sub)
        }
        return array[row-1]
    }
    
}
