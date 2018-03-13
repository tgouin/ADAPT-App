//
//  trainingToCSV.swift
//  Adapt
//
//  Created by Josh Altabet on 2/7/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit

class ExportToCSV{
    
    static func trainingToCSV(training: Training) -> String {
        var csvText: String!
        csvText = "Base Type,Training Type,Leg Used,Training Duration,Training Date\n"
        csvText.append("\(BaseType.toString(baseType: BaseType(rawValue: Int(training.baseType))!)),\(TrainingType.toString(trainingType: TrainingType(rawValue: Int(training.trainingType))!)),\(LegType.toString(legType: LegType(rawValue: Int(training.legType))!)),\(training.duration) seconds,\(training.dateTime!)\n")
        if let biasPoint = training.biasPoint as? CGPoint {
            csvText.append("Bias X Angle,Bias Y Angle,Score\n")
            csvText.append("\(biasPoint.x),\(biasPoint.y),\(training.score)\n")
        }
        csvText.append("X Angle,Y Angle\n")
        if let data = training.data as? [CGPoint] {
            for dataPoint in data {
                let newLine = "\(dataPoint.x),\(dataPoint.y)\n"
                csvText.append(contentsOf: newLine)
            }
        }
        
        return csvText
        
    }
    
    static func playerToCSV(player:Player) -> String {
        var csvText: String!
        csvText = "Name, Number,Height,Weight,Position\n"
        csvText.append("\(player.name),\(player.number),\(player.height),\(player.weight),\(player.position!)\n")
//        csvText.append("Easy Base Trainings\n")
//        let easy = player.id
//        csvText.append(trainingToCSV(training: easy!))
        
        /*csvText.append("Medium Base Trainings\n")
        for medium in player.mediumBase{
            csvText.append(trainingToCSV(training: medium))
        }
        csvText.append("Hard Base Trainings\n")
        for hard in player.hardBase{
            csvText.append(trainingToCSV(training: hard))
        }*/
        return csvText
    }
    
    
}
