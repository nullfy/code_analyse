//
//  Medium_082_Remove_Duplicates_From_Sorted_List_II.swift
//  algorithms
//
//  Created by null on 2018/4/26.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/
 
 #82 Remove Duplicates from Sorted List II
 
 Level: medium
 
 Given a sorted linked list, delete all nodes that have duplicate numbers, leaving only distinct numbers from the original list.
 
 For example,
 Given 1->2->3->3->4->4->5, return 1->2->5.
 Given 1->1->1->2->3, return 2->3.
 
 Inspired by @snowfish at https://leetcode.com/discuss/12724/my-accepted-java-code
 
 */


import Foundation

class Medium_082_Remove_Duplicated_From_Sorted_Array_II {
    class ListNode {
        var val: Int
        var next: ListNode?
        init(_ val: Int) {
            self.val = val
            self.next = nil
        }
    }
    class func deleteDuplicateds(_ head: ListNode?) -> ListNode? {
        /*if head == nil {
            return nil
        }
        
        let fakeHead = ListNode(val: 0, next: nil)
        fakeHead.next = head
        var prev: ListNode? = fakeHead
        var curr: ListNode? = head
        while curr != nil {
            while curr?.next != nil && curr?.val == curr?.next?.val {
                curr = curr?.next
            }
            
            if prev?.next === curr {
                prev = prev?.next
            } else {
                prev?.next = curr?.next
            }
            curr = curr?.next
        }
        return fakeHead.next
         */
        //top submission
        guard head != nil else { return nil }
        let ans = ListNode.init(0)
        var p = head
        var q = ans
        var dup = Int.min
        while p != nil {
            if p?.val != p?.next?.val && p?.val != dup {
                let temp = ListNode.init((p?.val)!)
                q.next = temp
                q = q.next!
            } else {
                dup = (p?.val)!
            }
            p = p?.next
        }
        return ans.next
    }
}
