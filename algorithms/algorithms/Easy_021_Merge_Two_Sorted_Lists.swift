//
//  Easy_021_Merge_Two_Sorted_Lists.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/14.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa

/*
 
 https://leetcode.com/problems/merge-two-sorted-lists/
 
 #21 Merge Two Sorted Lists
 
 Level: easy
 
 Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.
 
 Inspired by @xiaohui7 at https://leetcode.com/discuss/18986/14-line-clean-c-solution
 题解：合并两个已排序的链表b遍历 
 
 */
class Easy_021_Merge_Two_Sorted_Lists: NSObject {
    class Node {
        var value: Int
        var next: Node?
        init(value: Int = 0, next: Node? = nil) {
            self.value = value
            self.next = next
            
        }
    }
    
    class func mergeTwoLists(list1: Node?, list2: Node?) -> Node? {
        var l1 = list1
        var l2 = list2
        let dummy: Node = Node()
        var cursor: Node? = dummy
        while l1 != nil && l2 != nil {
            if (l1?.value)! < (l2?.value)! {
                cursor?.next = l1
                l1 = l1?.next
            } else {
                cursor?.next = l2
                l2 = l2?.next
            }
            cursor = cursor?.next
        }
        cursor?.next = l1 != nil ? l1 : l2
        return dummy.next
    }
}
