//
//  Easy_083_Remove_Duplicates_From_Sorted_List.swift
//  algorithms
//
//  Created by 李晓东 on 2017/9/27.
//  Copyright © 2017年 XD. All rights reserved.
//

import Cocoa
/*
 
 https://leetcode.com/problems/remove-duplicates-from-sorted-list/
 
 #83 Remove Duplicates from Sorted List
 
 Level: easy
 
 Given a sorted linked list, delete all duplicates such that each element appear only once.
 
 For example,
 Given 1->1->2, return 1->2.
 Given 1->1->2->3->3, return 1->2->3.
 
 Inspired by @Tao2014 at https://leetcode.com/discuss/7188/concise-solution-and-memory-freeing
 题解：有序链表原地移除重复元素
 1、由于是链表，所以有点不一样，主要是体现在表尾元素的赋值上
 2、从链表的头节点开始遍历
 3、如果当前节点等于下一节点的value，将current的下一节点指向current->next->next
 */

class Node {
    var val: Int
    var next: Node?
    init(value: Int, next: Node?) {
        self.val = value
        self.next = next
    }
}

class Easy_081_Remove_Duplicates_From_Sorted_List: NSObject {
    class func deleteDuplicate(_ head: Node?) -> Node? {
        if head == nil {
            return nil
        }
        var current: Node? = head
        while current?.next != nil {
            if current?.val == current?.next?.val {
                current?.next = current?.next?.next
            } else {
                current = current?.next
            }
        }
        return head
    }
}

