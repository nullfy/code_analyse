//
//  Medium_095_Unique_Binary_Search_Trees_II.swift
//  algorithms
//
//  Created by null on 2018/5/31.
//  Copyright © 2018年 XD. All rights reserved.
//

import Foundation

class Medium_095_Unique_Binary_Search_Trees_II {
    class Node {
        var val: Int
        var left: Node?
        var right: Node?
        init(val: Int, left: Node?, right: Node?) {
            self.val = val
            self.left = left
            self.right = right
        }
    }
    
    private class func genTree(start: Int, end: Int) -> [Node?] {
        var ret: [Node?] = []
        if start > end {
            ret.append(nil)
            return ret
        } else if start == end {
            ret.append(Node.init(val: 1, left: nil, right: nil))
            return ret
        }
        
        var left: [Node?] = []
        var right: [Node?] = []
        for i in start...end {
            left = genTree(start: start, end: i - 1)
            right = genTree(start: i+1, end: end)
            for left_node in left {
                for right_node in right {
                    let root = Node.init(val: 1, left: left_node, right: right_node)
                    ret.append(root)
                }
            }
        }
        return ret
    }
    class func generateTrees(_ n: Int) -> [Node?] {
        return genTree(start: 1, end: n)
    }
}
