//
//  TrainingSetupPopoverViewController.swift
//  Adapt
//
//  Created by Josh Altabet on 2/5/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit

class TrainingSetupPopoverViewController: UITableViewController{
    var delegate: SavingViewControllerDelegate?
    var optionType: OptionType = OptionType.Base
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(optionType) {
            case .Base:
                return BaseType.count()
            case .Training:
                return TrainingType.count()
            case .Leg:
                return LegType.count()
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var button = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath as IndexPath) as UITableViewCell
        let label = button.viewWithTag(1) as! UILabel
        let text: String
        switch(optionType) {
        case .Base:
            text = BaseType.toString(baseType: BaseType(rawValue: indexPath.row)!)
            break
        case .Training:
            text = TrainingType.toString(trainingType: TrainingType(rawValue: indexPath.row)!)
            break
        case .Leg:
            text = LegType.toString(legType: LegType(rawValue: indexPath.row)!)
            break
        }
        
        label.text = text
        return button
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        storyBoard.instantiateViewController(withIdentifier: "trainingSetup") as! TrainingSetupViewController
        
        //delegate?.saveText(strText: selectedValue, setupParam: setupParam)
        switch(optionType) {
        case .Base:
            delegate?.saveBaseType(baseType: BaseType(rawValue: indexPath.row)!)
            break
        case .Training:
            delegate?.saveTrainingType(trainingType: TrainingType(rawValue: indexPath.row)!)
            break
        case .Leg:
            delegate?.saveLegType(legType: LegType(rawValue: indexPath.row)!)
            break
        }
        dismiss(animated: true, completion: nil)
        
        
    }
}

protocol SavingViewControllerDelegate{
//    func saveText(strText: String, setupParam: Int)
    func saveBaseType(baseType: BaseType)
    func saveTrainingType(trainingType: TrainingType)
    func saveLegType(legType: LegType)
}


