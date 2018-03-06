//
//  LegType.swift
//  Adapt
//
//  Created by Timmy Gouin on 2/11/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation

enum LegType: Int {
    case Left = 0,
    Right,
    Both
    
    static func toString(legType: LegType) -> String {
        switch(legType) {
        case LegType.Left:
            return "Left"
        case LegType.Right:
            return "Right"
        case LegType.Both:
            return "Both"
        }
        return ""
    }
    
    static func count() -> Int {
        // NOTE: this should be the last enum value and will need to be updated with changes
        return LegType.Both.hashValue + 1
    }
}
