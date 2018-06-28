//
//  Hard_023_Merge_K_Sorted_Lists.swift
//  algorithms
//
//  Created by null on 2018/6/28.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

/*
 
 https://leetcode.com/problems/merge-k-sorted-lists/
 
 #23 Merge k Sorted Lists
 
 Level: hard
 
 Merge k sorted linked lists and return it as one sorted list. Analyze and describe its complexity.
 
 Inspired by @wksora at https://leetcode.com/discuss/9279/a-java-solution-based-on-priority-queue
 题解： 合并链表组成的已排序数组
 类似快排，两个指针，比较大小，小的挂一边组成链表，大的挂一边组成链表再重新组合一下
 */

class Hard_023_Merge_K_Sorted_Lists {
    class Node {
        var val: Int
        var next: Node?
        
        init(val: Int, next: Node?) {
            self.val = val
            self.next = next
        }
    }
    
    class func mergeTwoLists(l1 list1: Node?, l2 list2: Node?) -> Node? {
        var l1 = list1
        var l2 = list2
        
        if l1 == nil { return l2 }
        if l2 == nil { return l1 }
        
        var cur: Node? = nil
        var prev: Node? = nil
        while l1 != nil && l2 != nil {
            if (l1?.val)! > (l2?.val)! {
                if prev == nil {
                    prev = l2
                } else {
                    prev?.next = l2
                }
                
                if cur == nil {
                    cur = prev
                } else {
                    prev = prev?.next
                }
                l2 = l2?.next
            } else {
                if prev == nil {
                    prev = l1
                } else {
                    prev?.next = l1
                }
                
                if cur == nil {
                    cur = prev
                } else {
                    prev = prev?.next
                }
                l1 = l1?.next
            }
        }
        if l2 != nil {
            l1 = l2
        }
        prev?.next = l1
        return cur
    }
    
    class func mergeKLists(_ list: [Node?]) -> Node? {
        if list.count == 0 {
            return nil
        } else if list.count == 1 {
            return list[0]
        } else if list.count == 2 {
            return mergeTwoLists(l1: list[0], l2: list[1])
        } else {
            return mergeTwoLists(l1: mergeKLists(Array(list[0..<list.count/2])), l2: mergeKLists(Array(list[list.count/2 ..< list.count])))
        }
        
    }
}
