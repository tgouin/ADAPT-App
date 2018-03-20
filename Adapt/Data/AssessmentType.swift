//
//  TestOrTrainingType.swift
//  Adapt
//
//  Created by Josh Altabet on 3/19/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation

enum AssessmentType: Int {
    case Training = 0,
    Test;
    
    static func toString(assessmentType: AssessmentType) -> String{
        switch(assessmentType) {
        case AssessmentType.Training:
            return "Training"
        case AssessmentType.Test:
            return "Test"
        }
        return ""
    }
    
    static func count() -> Int {
        // NOTE: this should be the last enum value and will need to be updated with changes
        return AssessmentType.Test.hashValue + 1
    }
}
