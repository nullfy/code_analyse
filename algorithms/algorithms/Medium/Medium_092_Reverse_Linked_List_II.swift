//
//  Medium_092_Reverse_Linked_List_II.swift
//  algorithms
//
//  Created by null on 2018/5/21.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

struct Medium_092_Reverse_Linked_List_II {
    class Node {
        var value: Int
        var next: Node?
        init(value: Int, next: Node?) {
            self.value = value
            self.next = next
        }
    }
    
    
    static func reverseBetween(_ head: Node?, m: Int, n: Int) -> Node? {
        //链表操作
        
        if head == nil {
            return nil
        }
        
        let dummy: Node = Node(value: 0, next: head)
        var pre: Node? = dummy
        for _ in 0 ..< m - 1 {
            pre = pre?.next
        }
        
        let start: Node? = pre?.next
        var then: Node? = start?.next
        for _ in 0 ..< n - m {
            start?.next = then?.next
            then?.next = pre?.next
            pre?.next = then
            then = start?.next
        }
        return dummy.next
    }
}
