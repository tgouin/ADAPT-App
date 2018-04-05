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
    
    @IBOutlet weak var target: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var titleText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTrainings()
        if let unwrappedTitle = titleText {
            titleLabel.text = unwrappedTitle
        }
        MainViewController.drawCircle(imageView: target)
        for training in trainingsList {
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
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func fetchTrainings() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let trainingsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Training")
        //trainingsFetch.predicate = NSPredicate(format: "playerId == %@", <#T##args: CVarArg...##CVarArg#>)
        do {
            let fetchedTrainings = try appDelegate.dataController.managedObjectContext.fetch(trainingsFetch) as! [Training]
            self.trainingsList = fetchedTrainings
        } catch {
            fatalError("Failed to fetch players: \(error)")
        }
    }
}
