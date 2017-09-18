//
//  main.swift
//  algorithms
//
//  Created by 李晓东 on 2017/5/2.
//  Copyright © 2017年 Xiaodong. All rights reserved.
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
for i in 1...1000 {
    if i > 1 {
        a += 2
        num.append(a)
    } else {
        num.append(a)
    }
}


//let target = 16021;
//var solu = Solution()
//var sum = solu.twoSum(num, target);



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

/*
let num3 = [7, 9, 10];
let num2 = [1, 3, 5];
let m = SortArary().findMedianSortedArrays(num3, num2);
print(m);
*/

//var arr = [1,2,2,2,4]
//let ali = leetcode.removeElment(array: &arr, n: arr.count, elem: 2)

//var arr = [1,4,4,6,7,8]
//let ali = leetcode.removeDupliteFromSortedArray(array: &arr)

//var arr = [1,3,3,3,5,5,7,8]
//let ali = leetcode.removeMultipDupliteFromSortedArray(array: &arr)

//var arr = [1,9,9,9]
//let ali = leetcode.plusOne(array: &arr)

//let ali = leetcode.generatePascaltriangle(row: 8)

//let ali = leetcode.mergeSortedArray(array1: num2, array2: num3)


//let sumNum = [1,7,10,19,27,19];
//let ali = leetcode.twoSumSolution(num, 12);

//let minimumArray = [7, 2, 6, 4 , 0, 1, 5, 3];
//let ali = leetcode.findMinimunNumInRotateArray(minimumArray)
//let ali = leetcode.Medium_003_Longest_Substring_Without_Repeating_Characters.longest("aaabbbdeedb")

//let sortA = [11]
//let sortB = [1]
//let ali = leetcode.Hard_004_Median_Of_Two_Sorted_Arrays.findMedianSortedArrays(smallArray: sortA, bigArray: sortB)

//let ali = leetcode.Easy_001_Palindrome_Number.isPalindromeNumber(1221)

//let ali = leetcode.Easy_006_ZigZag_Conversion.convert(s: "HPLJLKJHKGHGKJHKJH", nRows: 3)
//var array = [88, 9 , 2, 3, 100]
//let ali = leetcode.Easy_selectSort.sortArray(&array)
//let ali = leetcode.Easy_insertSort.sort(&array)
//let ali = leetcode.Easy_008_String_to_Integer_atoi.atoi("-09")

//let s = "kajdklajfalkjdfal;k"
//print(s.characters.count,"---\n", s[s.characters.index(s.startIndex, offsetBy: 4)]) //s[6] 直接下标是不行的

//var array = [1, 1, 3, 3, 4, 4]
//let ali = Easy_026_Remove_Duplicates_From_Sorted_Array.removeDuplicated(&array)

let ali = Easy_028_Implement_Str.strStr_brute_force(hayStack: "hehe", needle: "eh")
print(ali)
