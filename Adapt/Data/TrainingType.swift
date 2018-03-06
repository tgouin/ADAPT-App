//
//  TrainingType.swift
//  Adapt
//
//  Created by Timmy Gouin on 2/11/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation

enum TrainingType: Int {
    case Target = 0,
    Bar;
    
    static func toString(trainingType: TrainingType) -> String {
        switch(trainingType) {
        case TrainingType.Target:
            return "Target"
        case TrainingType.Bar:
            return "Bar"
            
        }
        return ""
    }
    
    static func count() -> Int {
        // NOTE: this should be the last enum value and will need to be updated with changes
        return TrainingType.Bar.hashValue + 1
    }
}
