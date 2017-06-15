//
//  main.swift
//  algorithms
//
//  Created by 李晓东 on 2017/5/2.
//  Copyright © 2017年 XD. All rights reserved.
//

import Foundation

/**
 Given nums = [2, 7, 11, 15], target = 9,
 
 Because nums[0] + nums[1] = 2 + 7 = 9,
 return [0, 1].
 */

class Solution {
    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
//        var arras = [Int]();
//        for  i in 0...nums.count-1 {
//            let j = i + 1;
//            for j in j...nums.count-1 {
//                let x = nums[j]
//                let y = nums[i]
//                if x == target - y {
//                    arras.append(i);
//                    arras.append(j);
//                    return arras;
//                }
//            }
//        }
//        return arras
        
        
        //solution 2
        var dic: [String: String] = [:];
        var array: Array<Int> = [];
        var tag = 0;
        for i in nums {
            let indexString = String.init(format: "%i", tag);
            let result = target - i;
            let resultString = String.init(format: "%i", result);
            let iString = String.init(format: "%i", i);
            if dic.keys.contains(resultString) {
                let index = dic.index(forKey: resultString);
                array.append(Int(dic[index!].value)!);
                array.append(tag);
                return array;
            } else {
                dic[iString] = indexString;
            }
            tag += 1;
        }
        return array;
    }
}



var num: [Int] = []
var a = 2
for i in 1...90 {
    if i > 2 {
        num.append(a)
        a += 2
        continue
    }
    num.append(a)
}


let target = 16021;
var solu = Solution()
var sum = solu.twoSum(num, target);



class SortArary {
//    func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
//        var a : Double! = 0;
//        let array = NSMutableArray.init(array: nums1);
//        array.addObjects(from: nums2);
//        quickSort(array: array, left: 0, right: array.count - 1);
//        print(array);
//        let m = nums1.count + nums2.count;
//        let n = Int(ceil(Double(array.count/2)));
//        print(n, array[n], array);
//        if m % 2 == 0 {
//            a = Double((array[n] as! Int) + (array[n - 1] as! Int)) / 2;
//        } else {
//            a = Double(array[n] as! Int);
//        }
//        return a;
//    }
//    
//    func quickSort(array: NSMutableArray, left: Int, right: Int) {
//        if left >= right {
//            return;
//        }
//        var i = left;
//        var j = right;
//        let key = array[i] as! Int;
//        while i < j{
//            while i < j && array[j] as! Int >= key  {
//                j -= 1;
//            }
//            array[i] = array[j];
//            
//            while i < j && (array[i] as! Int) <= key  {
//                i += 1;
//            }
//            array[j] = array[i];
//        }
//        array[i] = key;
//        
//        quickSort(array: array, left: left, right: i - 1);
//        quickSort(array: array, left: i + 1, right: right);
//    }
    func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
        //let start = CFAbsoluteTimeGetCurrent();
        var a : Double! = 0;
        var array = Array<Int>.init();
        
        array.append(contentsOf: nums1);
        array.append(contentsOf: nums2);
        
        var left = 0;
        var right = array.count - 1;
        quickSort(array: &array, left: &left, right: &right);
        //print(array);
        let m = nums1.count + nums2.count;
        let n = Int(ceil(Double(array.count/2)));
        //print(n, array[n], array);
        if m % 2 == 0 {
            a = Double((array[n]) + (array[n - 1])) / 2;
        } else {
            a = Double(array[n] );
        }
        //let end = CFAbsoluteTimeGetCurrent();
        //print(end - start);
        return a;
    }
    
    func quickSort(array:inout Array<Int>, left:inout Int, right:inout Int) {
        if left >= right {
            return;
        }
        var i = left;
        var j = right;
        let key = array[i];
        while i < j{
            while i < j && array[j]  >= key  {
                j -= 1;
            }
            array[i] = array[j];
            
            while i < j && array[i]  <= key  {
                i += 1;
            }
            array[j] = array[i];
        }
        array[i] = key;
        var tempLeft = i + 1;
        var tempRight = i - 1;
        quickSort(array: &array, left: &left, right: &tempRight);
        quickSort(array: &array, left: &tempLeft, right: &right);
    }

}

//
let num3 = [7, 9, 10];
let num2 = [1, 3, 5];
let m = SortArary().findMedianSortedArrays(num3, num2);
//print(m);

//var arr = [1,2,2,2,4]
//let ali = leetcode.removeElment(array: &arr, n: arr.count, elem: 2)

//var arr = [1,4,4,6,7,8]
//let ali = leetcode.removeDupliteFromSortedArray(array: &arr)

//var arr = [1,3,3,3,5,5,7,8]
//let ali = leetcode.removeMultipDupliteFromSortedArray(array: &arr)

//var arr = [1,9,9,9]
//let ali = leetcode.plusOne(array: &arr)

//let ali = leetcode.generatePascaltriangle(row: 8)

let ali = leetcode.mergeSortedArray(array1: num2, array2: num3)
print(ali)