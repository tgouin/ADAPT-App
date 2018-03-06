//
//  SettingsViewController.swift
//  Adapt
//
//  Created by Josh Altabet on 2/1/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    var playerProfile: Player?
    
    
    @IBAction func connectToSensor(_ sender: Any) {
        performSegue(withIdentifier: "connectToSensor", sender: nil)
        
    }
    
    @IBAction func exportPlayerProfile(_ sender: Any) {
        let fileName = "player.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        if let unwrappedPlayer = playerProfile {
            let csvText = ExportToCSV.playerToCSV(player: unwrappedPlayer)
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                vc.popoverPresentationController?.sourceView = self.view
                vc.excludedActivityTypes = [
                    UIActivityType.assignToContact,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.postToFlickr,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo,
                    UIActivityType.postToTwitter,
                    UIActivityType.postToFacebook,
                    UIActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
        } else {
            print("no player data")
        }
        
        
        
        
    }
    
    @IBAction func showAngleValidationView(_ sender: Any) {
        performSegue(withIdentifier: "showAngleValidation", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func unwindToDashboard(segue: UIStoryboardSegue){}
    
    
}
