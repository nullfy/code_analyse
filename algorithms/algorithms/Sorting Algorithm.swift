//
//  Sorting Algorithm.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/30.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

class Sorting_Algorithm: NSObject {
    //冒泡
    class func Bubble_sort(arr: [Int], n: Int) -> [Int] {
        if arr.count == 1 {
            return arr
        }
//        var res = arr
//        var tmp = 0
//        for i in 0..<n {
//            for j in 1..<n-i {
//                if res[j] < res[j-1] {
//                   tmp = res[j]
//                    res[j] = res[j-1]
//                    res[j-1] = tmp
//                }
//                print(res)
//            }
//        }
        var res = arr
        var tmp = 0
        for i in 0..<n {
            for j in 0..<n-i {
                if res[j + 1] < res[j] {
                    tmp = res[j]
                    res[j] = res[j + 1]
                    res[j + 1] = tmp
                }
            }
        }
        return res
    }
    
    /*
     插入排序的重点在于选中的数在第一层循环中递增，同时已i 为起点递减向前找i值 合适的位置
     注意点是选择的目标值从1开始， j往前走的时候有为-1的情况
     */
    class func Insert_sort(arr: [Int], n: Int) -> [Int] {
        if arr.count == 1 {
            return arr
        }
        var res = arr
        var j = 0
        var tmp = 0
        for i in 1..<n {
            tmp = res[i];
            /*
            while(j >= 0 && res[j] > tmp) {
                res[j+1] = res[j];
                j -= 1;
                print("----",res)
            }
            res[j+1] = tmp; //res[j] j可能为-1
             */
            for m in (0...(i-1)).reversed() {
                if res[m] > tmp {
                    res[m+1] = res[m]
                    res[m] = tmp
                    print("---------",res)
                    continue
                } else {
                    j = m
                    break;
                }
                //print("----",res)
            }
            res[j+1] = tmp
            print(res)
        }
        return res
    }
    
    //选择排序是找到数组中最小的数，然后替换暂定的最大值和最小值，最大值一般是第一层中的i
    class func Select_sort(arr: [Int], n: Int) -> [Int] {
        if arr.count == 1 {
            return arr
        }
        var res = arr
        var min = 0
        var tmp = 0
        for i in 0..<n {
            min = i
            tmp = res[i]
            for j in i+1..<n {
                if res[j] < res[min] {
                    min = j //这里的循环主要是找到最小值
                }
            }
            res[i] = res[min]
            res[min] = tmp
        }
        return res
    }
    
    class func Shell_sort(arr: [Int], n: Int) -> [Int] {
        var tmp = 0
        var gap = 1
        var res = arr
        var j = 0
        while gap < n/3 {
            gap = gap*3 + 1
        }
        print("----gap",gap)
        while gap > 0 {
            for i in gap..<n {
                tmp = res[i]
                j = i - gap
                print("----j",j)
                while j >= 0 && res[j] > tmp {
                    res[j+gap] = res[j]
                    j -= gap
                    print("while-loop\(j)-------arr",res)
                }
                res[j+gap] = tmp
                print("第\(i)次loop----arr",res)
            }
            gap = Int(floor(Double(gap/3)))
        }
        return res
    }
    
}

