//
//  trainingPagedViewController.swift
//  Adapt
//
//  Created by Josh Altabet on 2/12/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit

class trainingPagedViewController: UIViewController{

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.drawCircle(imageView: self.view?.viewWithTag(1) as! UIImageView)

        self.view.layoutIfNeeded()
    }
}
