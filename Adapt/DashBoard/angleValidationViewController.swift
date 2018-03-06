//
//  angleValidationViewController.swift
//  Adapt
//
//  Created by Josh Altabet on 2/28/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class angleValidationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var sensorAnglesLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    var buttonPressedCount = 0;
    
    var lastEuler: Euler = Euler(yaw: 0, pitch: 0, roll: 0)
    var hasReceivedData = false
    var locationManager:CLLocationManager = CLLocationManager()
    
    var tareOffsetX: CGFloat = 0
    var tareOffsetY: CGFloat = 0
    var forward: CGPoint = CGPoint(x: 0, y: 0)
    var back: CGPoint = CGPoint(x: 0, y: 0)
    var left: CGPoint = CGPoint(x: 0, y: 0)
    var right: CGPoint = CGPoint(x: 0, y: 0)
    
    
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if (!hasReceivedData) {
            let noDeviceAlert = UIAlertController(title: "Not Connected", message: "Please turn on the device and make sure Bluetooth is enabled", preferredStyle: UIAlertControllerStyle.alert)
            noDeviceAlert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (alertAction) in
                noDeviceAlert.dismiss(animated: true, completion: nil)
            }))
            present(noDeviceAlert, animated: true, completion: nil)
            return
        }
        
        buttonPressedCount = buttonPressedCount + 1
        switch self.buttonPressedCount {
        case 1:
            self.tareOffsetX = -CGFloat(lastEuler.roll)
            self.tareOffsetY = -CGFloat(lastEuler.pitch)
            
            self.instructionLabel.text = "2. Secure the 1D Base to the bottom of the board\nso that the board can be tilted towards and away from the iPad "
            self.buttonLabel.setTitle("Done", for: .normal)
            
        case 2:
            self.instructionLabel.text = "3. Push board all the way to\nthe front and press 'NEXT'"
            self.buttonLabel.setTitle("Next", for: .normal)
            
        case 3:
            self.forward.x = -CGFloat(lastEuler.roll)
            self.forward.y = -CGFloat(lastEuler.pitch)
            
            self.instructionLabel.text = "4. Push board all the way to\nthe back and press 'NEXT'"
            self.buttonLabel.setTitle("Next", for: .normal)
            
        case 4:
            self.back.x = -CGFloat(lastEuler.roll)
            self.back.y = -CGFloat(lastEuler.pitch)
            
            self.instructionLabel.text = "5. Rotate the 1D base 90 degrees\nand secure to the bottom of the board"
            self.buttonLabel.setTitle("Done", for: .normal)
            
        case 5:
            self.instructionLabel.text = "6. Push board all the way to\nthe left and press 'NEXT'"
            self.buttonLabel.setTitle("Next", for: .normal)
            
        case 6:
            self.left.x = -CGFloat(lastEuler.roll)
            self.left.y = -CGFloat(lastEuler.pitch)
            
            self.instructionLabel.text = "7. Push board all the way to\nthe right and press 'NEXT'"
            self.buttonLabel.setTitle("Next", for: .normal)
            
        case 7:
            self.right.x = -CGFloat(lastEuler.roll)
            self.right.y = -CGFloat(lastEuler.pitch)
            
            self.instructionLabel.text = "Zero Position: (\(self.tareOffsetX),\(self.tareOffsetY)\nForward: (\(self.forward.x),\(self.forward.y)\nBack: (\(self.back.x),\(self.back.y)\nLeft: (\(self.left.x),\(self.left.y)\nRight: (\(self.right.x),\(self.right.y)"
            self.buttonLabel.setTitle("Back to Dashboard", for: .normal)
            
        case 8:

            dismiss(animated: true, completion: nil)
            
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.instructionLabel.text = "1. Place board flat on ground so\nthat a reference point can be established"
        self.buttonLabel.setTitle("Calibrate", for: .normal)
        
        if let _ = UserDefaults.standard.string(forKey: BLEController.PERIPHERAL_UUID) {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.bleController.startScan()
            }
        } else {
            performSegue(withIdentifier: "bleDevices", sender: nil)
        }
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"SavedDeviceConnecting"),
                       object:nil, queue:nil) { notification in
                        self.sensorAnglesLabel.text = "Device found, connecting..."
        }
        nc.addObserver(forName:Notification.Name(rawValue:"DeviceData"),
                       object:nil, queue:nil) { notification in
                        //guard let quaternion = notification.object as? Quaternion else { return }
                        guard let euler = notification.object as? Euler else { return }
                        self.hasReceivedData = true
                        self.lastEuler = euler
                        let newX = -CGFloat(euler.roll) * MainViewController.EULER_SCALAR
                        let newY = -CGFloat(euler.pitch) * MainViewController.EULER_SCALAR
                        let rollString = String(format: "%.1f", newX / MainViewController.EULER_SCALAR)
                        let pitchString = String(format: "%.1f", newY / MainViewController.EULER_SCALAR)
                        self.sensorAnglesLabel.text = "Sensor Data\nX: \(rollString)°\nY: \(pitchString)°"
                        self.view.layoutIfNeeded()
                        
        }
    }
}
