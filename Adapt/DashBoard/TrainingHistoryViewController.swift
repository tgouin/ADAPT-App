//
//  trainingPagedViewController.swift
//  Adapt
//
//  Created by Josh Altabet on 2/12/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TrainingHistoryViewController: UIViewController{
    var trainingsList = [Training]()
    let playerID = 3
    
    @IBOutlet weak var target: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var targetWidth: NSLayoutConstraint!
    @IBOutlet weak var targetHeight: NSLayoutConstraint!
    
    var titleText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchTrainings()
        if let unwrappedTitle = titleText {
            titleLabel.text = unwrappedTitle
            if titleText == "overall"{
                self.target.isHidden = true
                
                let numTrainingsLabel = UILabel(frame: CGRect(x: 30, y: 100, width: 400, height: 30))
                let numTrainings = fetchTrainings(playerID: self.playerID).count
                numTrainingsLabel.text = "Total number of Trainings = \(numTrainings)"
                numTrainingsLabel.textColor = UIColor.white
                self.view.addSubview(numTrainingsLabel)
                
                let numTrainingsLabelEasy = UILabel(frame: CGRect(x: 30, y: 140, width: 400, height: 30))
                let numTrainingsEasy = fetchTrainings(playerID: self.playerID, predicate: "baseType", predArg: 0).count
                numTrainingsLabelEasy.text = "Total number of Easy Base Trainings = \(numTrainingsEasy)"
                numTrainingsLabelEasy.textColor = UIColor.white
                self.view.addSubview(numTrainingsLabelEasy)
                
                let averageScoreLabelEasy = UILabel(frame: CGRect(x: 70, y: 180, width: 400, height: 30))
                let averageScoreEasy = averageScore(trainingList: fetchTrainings(playerID: self.playerID, predicate: "baseType", predArg: 0))
                averageScoreLabelEasy.text = "Easy Base Average Score = \(averageScoreEasy)"
                averageScoreLabelEasy.textColor = UIColor.white
                self.view.addSubview(averageScoreLabelEasy)
                
                let numTrainingsLabelMedium = UILabel(frame: CGRect(x: 30, y: 220, width: 400, height: 30))
                let numTrainingsMedium = fetchTrainings(playerID: self.playerID, predicate: "baseType", predArg: 1).count
                numTrainingsLabelMedium.text = "Total number of Medium Base Trainings = \(numTrainingsMedium)"
                numTrainingsLabelMedium.textColor = UIColor.white
                self.view.addSubview(numTrainingsLabelMedium)
                
                let averageScoreLabelMedium = UILabel(frame: CGRect(x: 70, y: 260, width: 400, height: 30))
                let averageScoreMedium = averageScore(trainingList: fetchTrainings(playerID: self.playerID, predicate: "baseType", predArg: 1))
                averageScoreLabelMedium.text = "Medium Base Average Score = \(averageScoreMedium)"
                averageScoreLabelMedium.textColor = UIColor.white
                self.view.addSubview(averageScoreLabelMedium)
                
                let numTrainingsLabelHard = UILabel(frame: CGRect(x: 30, y: 300, width: 400, height: 30))
                let numTrainingsHard = fetchTrainings(playerID: self.playerID, predicate: "baseType", predArg: 2).count
                numTrainingsLabelHard.text = "Total number of Hard Base Trainings = \(numTrainingsHard)"
                numTrainingsLabelHard.textColor = UIColor.white
                self.view.addSubview(numTrainingsLabelHard)
                
                let averageScoreLabelHard = UILabel(frame: CGRect(x: 70, y: 340, width: 400, height: 30))
                let averageScoreHard = averageScore(trainingList: fetchTrainings(playerID: self.playerID, predicate: "baseType", predArg: 2))
                averageScoreLabelHard.text = "Hard Base Average Score = \(averageScoreHard)"
                averageScoreLabelHard.textColor = UIColor.white
                self.view.addSubview(averageScoreLabelHard)

                
                
                
            }
            else if titleText == "easy eversion/inversion"{
                self.targetWidth.constant = 400
                self.targetHeight.constant = 100
                OneDBarTrainingViewController.drawBarRect(imageView: target)
                
            }
            else if titleText == "easy dorsiflexion/plantarflexion"{
                self.targetWidth.constant = 100
                self.targetHeight.constant = 400
                OneDBarTrainingViewController.drawBarRect(imageView: target)
            }
            else if titleText == "medium"{
                self.targetWidth.constant = 350
                self.targetHeight.constant = 350
                MainViewController.drawCircle(imageView: target)
            }
            else if titleText == "hard"{
                self.targetWidth.constant = 350
                self.targetHeight.constant = 350
                MainViewController.drawCircle(imageView: target)
            }
        }
        

        /*for training in trainingsList {
            let pointView = UIImageView(frame: CGRect(x: target.frame.midX, y: target.frame.midY, width: 5, height: 5))
            let pointConstraintX = NSLayoutConstraint(item: pointView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: target, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let pointConstraintY = NSLayoutConstraint(item: pointView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: target, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)

            if let biasPoint = training.biasPoint as? CGPoint{
                pointConstraintX.constant = biasPoint.x * MainViewController.EULER_SCALAR * 0.445714285714286
                pointConstraintY.constant = biasPoint.y * MainViewController.EULER_SCALAR * 0.445714285714286
            }
            
            self.view.addSubview(pointView)
            self.view.addConstraint(pointConstraintX)
            self.view.addConstraint(pointConstraintY)
            MainViewController.drawPoint(imageView: pointView)
        }*/
        //self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func fetchTrainings(playerID: Int, predicate: String? = nil, predArg: Int? = nil) -> [Training] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let trainingsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Training")
        let p1 = NSPredicate(format: "playerId == %@", NSNumber(value: playerID))
        if let cvArg = predArg {
            let p2 = NSPredicate(format: "\(predicate!) == %@", NSNumber(value: cvArg))
            trainingsFetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        }
        else {
            trainingsFetch.predicate = p1
        }

        do {
            let fetchedTrainings = try appDelegate.dataController.managedObjectContext.fetch(trainingsFetch) as! [Training]
            return fetchedTrainings
        } catch {
            fatalError("Failed to fetch players: \(error)")
        }
    }
    
    func averageScore(trainingList: [Training]) -> Double {
        if trainingList.count == 0{
            return 0.0
        }
        var runningScore:Float = 0
        for training in trainingList {
            runningScore += training.score
        }
        return Double(runningScore)/Double(trainingList.count)
    }
}
