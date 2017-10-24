//
//  Medium_011_Container_With_Most_Water.swift
//  algorithms
//
//  Created by 李晓东 on 2017/10/24.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

/*
 https://leetcode.com/problems/container-with-most-water/
 
 #11 Container With Most Water
 
 Level: medium
 
 Given n non-negative integers a1, a2, ..., an, where each represents a point at coordinate (i, ai). n vertical lines are drawn such that the two endpoints of line i is at (i, ai) and (i, 0). Find two lines, which together with x-axis forms a container, such that the container contains the most water.
 
 Note: You may not slant the container.
 
 Inspired by @franticguy at https://leetcode.com/discuss/14610/very-simple-o-n-solution
 
 题解：给定 n 个非负整数，每个元素对应的点是（i， ai） 如给定数组【1，4，5，6，9】
 对应的点就是(0, 1)、(1, 4)、（2, 5）、（3， 6）、（4，9）
 求的是数组中两个元素对应坐标，围城的四边形能装的水最多（也就是以短的高为准）
 
 */
class Medium_011_Container_With_Most_Water: NSObject {
    
    class func maxArea(heigthsArray: [Int]) -> Int {
        var j: Int = heigthsArray.count - 1
        var i: Int = 0
        var mx: Int = 0
        while i < j {
            mx = max(mx, (j - i) * min(heigthsArray[i], heigthsArray[j]))
            if heigthsArray[i] < heigthsArray[j] {
                i += 1
            } else {
                j -= 1
            }
            print("max is :\(mx) i is:\(i), j is \(j)")
        }
        return mx
    }

}
