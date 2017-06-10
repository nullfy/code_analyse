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
     */
    public class func removeElment(array: inout [Int], n: Int, elem: Int) -> Int {
        var i = 0
        var j = 0
        /*
         eg
         [1,2,2,4,5] target=2
         
         step1:[1,2,2,4,5] i=0 j=0
         step2:[1,2,2,4,5] i=1 j=0
         step3:[1,2,2,4,5] i=2 j=0
         step4:[1,4,2,4,5] i=3 j=1
         step5:[1,4,5,4,5] i=4 j=2
         */
        for _ in 1...n {
           if array[i] == elem {
                i += 1
                continue
            }
            array[j] = array[i]
            j += 1
            i += 1
        }
        return j
    }
    
    /*
     Given a sorted array, remove the duplicates in place such that > each element appear only once
     and return the new length.
     Do not allocate extra space for another array, you must do this in place with constant memory.
     For example, Given input array A = [1,1,2],
     Your function should return length = 2, and A is now [1,2].
     
     给定排序好的数组，移除重复项，返回去重后数组的个数
     ps:不能开辟新的空间
     */
    public class func removeDupliteFromSortedArray(array: inout [Int]) -> Int {
        if (array.count == 0) {
            return 0
        }
        var j = 1
        for i in 0...(array.count - 1) {
            if array[i] != array[j] {
                j+=1
                array[j] = array[i]
            }
        }
        return j+1
    }
    
    
    
}
