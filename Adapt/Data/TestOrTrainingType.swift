//
//  TestOrTrainingType.swift
//  Adapt
//
//  Created by Josh Altabet on 3/19/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation

enum TestOrTrainingType: Int {
    case Test = 0,
    Training;
    
    static func toString(testOrTrainingType: TestOrTrainingType) -> String{
        switch(testOrTrainingType) {
        case TestOrTrainingType.Test:
            return "Test"
        case TestOrTrainingType.Training:
            return "Training"
        }
        return ""
    }
    
    static func count() -> Int {
        // NOTE: this should be the last enum value and will need to be updated with changes
        return TestOrTrainingType.Training.hashValue + 1
    }
}
