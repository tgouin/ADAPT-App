//
//  OneDBarTrainingViewController.swift
//  Adapt
//
//  Created by Josh Altabet on 2/14/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class OneDBarTrainingViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var barView: UIImageView!
    @IBOutlet weak var barRectView: UIImageView!
    @IBOutlet weak var pointY: NSLayoutConstraint!
    @IBOutlet weak var pointX: NSLayoutConstraint!
    @IBOutlet weak var sensorDataView: UITextView!
    
    static var EULER_SCALAR: CGFloat = 16
    var tareOffset: CGPoint = CGPoint(x: 0, y: 0)
    var tareOffsetX: CGFloat = 0
    var tareOffsetY: CGFloat = 0
    var lastHeading: CGFloat = 0
    var lastEuler = Euler(yaw: 0, pitch: 0, roll: 0)
    
    var currentTraining: Training?
    var locationManager:CLLocationManager = CLLocationManager()
    var data: [CGFloat] = []
    
    var timer = Timer()
    var timerSeconds: Int32 = 0
    var timerRunning = false
    @IBOutlet weak var timerLabel: UILabel!
    
    var countdownTimer = Timer()
    var countdownSeconds: Int32 = 3
    var countdownRunning = false
    @IBOutlet weak var countdownLabel: UILabel!
    
    var totalSamples:Int32 = 0
    var runningTotal:CGFloat = CGFloat()
    var runningScore: CGFloat = 0
    
    var flexion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        timerLabel.text = "\(currentTraining!.duration) Seconds"
        countdownLabel.text = "\(countdownSeconds)"
        countdownLabel.layer.isHidden = true
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"DeviceData"),
                       object:nil, queue:nil) { notification in
                        //guard let quaternion = notification.object as? Quaternion else { return }
                        guard let euler = notification.object as? Euler else { return }
                        
                        
                        
                        if (self.timerRunning) {
                            self.lastEuler = euler
                            var trainingString = ""
                            if self.flexion{
                                let newY = (-CGFloat(euler.roll) * MainViewController.EULER_SCALAR - self.tareOffsetX) / MainViewController.EULER_SCALAR
                                self.pointY.constant = newY * MainViewController.EULER_SCALAR
                                self.runningTotal += newY
                                self.data.append(newY)
   
                                let pitchString = String(format: "%.1f", newY)
                                let average = self.getAverage()
                                let averageString = String(format: "%.1f", average)
                                let score = self.getScore(x: 0, y: newY)
                                
                                trainingString = self.timerRunning ? "\nAverage Y: \(averageString)\nScore: \(score)" : ""
                                self.sensorDataView.text = "\nY: \(pitchString)°\(trainingString)"
                            }
                            else{
                                let newX = -(-CGFloat(euler.pitch) * MainViewController.EULER_SCALAR - self.tareOffsetY) / MainViewController.EULER_SCALAR
                                self.pointY.constant = -newX * MainViewController.EULER_SCALAR
                                self.runningTotal += newX
                                self.data.append(newX)
                                
                                let rollString = String(format: "%.1f", newX)
                                let average = self.getAverage()
                                let averageString = String(format: "%.1f", average)
                                let score = self.getScore(x: newX, y: 0)
                                
                                trainingString = self.timerRunning ? "\nAverage X: \(averageString)\nScore: \(score)" : ""
                                self.sensorDataView.text = "\nX: \(rollString)°\(trainingString)"
                            }
                            self.totalSamples += 1
                        }
                        
                        self.view.layoutIfNeeded()
                        
        }
            
        OneDBarTrainingViewController.drawBarRect(imageView: barRectView);
        OneDBarTrainingViewController.drawBar(imageView: barView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.countdownSeconds = 3
        timerLabel.text = "\(currentTraining!.duration) Seconds"
        countdownLabel.text = "\(countdownSeconds)"
        
        lastEuler = Euler(yaw: 0, pitch: 0, roll: 0)
        data = []
        totalSamples = 0
        runningTotal = 0
        runningScore = 0
        self.pointX.constant = 0
        self.pointY.constant = 0
    }
    
    
    func getScore(x: CGFloat, y: CGFloat) -> CGFloat {
        let magnitude = sqrt(x * x + y * y)
        var score:CGFloat = 0
        if (magnitude < 5) {
            score = 1.0
            // bullseye
        } else if (magnitude < 10) {
            score = 0.75
        } else if (magnitude < 15) {
            score = 0.5
        } else if (magnitude < 20) {
            score = 0.25
        }
        self.runningScore += score
        var currentScore = CGFloat(round(CGFloat(self.runningScore) * 1000.0 / CGFloat(self.totalSamples))/10.0)
        if (currentScore > 100) {
            currentScore = 100
        }
        return currentScore
    }
    
    func getAverage() -> CGFloat {
        return CGFloat(runningTotal / CGFloat(totalSamples))
    }
    
    @IBAction func startTraining(_ sender: Any) {
        countdownRunning = true
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.updateCountdownLabel), userInfo: nil, repeats: true)
        countdownLabel.layer.isHidden = false
    }
    
    func trainingStart(){
        timerRunning = true
        runningTotal = 0
        timerSeconds = currentTraining?.duration ?? 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerLabel(sender: AnyObject?){
        timerSeconds = timerSeconds - 1
        timerLabel.text = "\(timerSeconds) Seconds"
        if timerSeconds == 0 {
            timer.invalidate()
            trainingEnded()
        }
    }
    
    @objc func updateCountdownLabel(sender: AnyObject?){
        countdownSeconds = countdownSeconds - 1
        countdownLabel.text = "\(countdownSeconds)"
        if countdownSeconds == 0 {
            countdownTimer.invalidate()
            countdownLabel.layer.isHidden = true
            trainingStart()
        }
    }
    
    func trainingEnded() {
        timerRunning = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let sensorTile = appDelegate.bleController.sensorTile {
            appDelegate.bleController.centralManager.cancelPeripheralConnection(sensorTile)
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "reviewTrainingViewController") as! ReviewTrainingViewController
        currentTraining?.data = data as NSObject
        currentTraining?.score = Float(getScore(x: 100, y: 100))
        if self.flexion{
            currentTraining?.biasPoint = CGPoint.init(x: CGFloat(0) , y: getAverage()) as NSObject
        } else {
            currentTraining?.biasPoint = CGPoint.init(x: getAverage(), y: CGFloat(0)) as NSObject
        }

        if let _ = currentTraining {
            do {
                try appDelegate.dataController.managedObjectContext.save()
            } catch {
                print ("failed to save training data")
            }
        }
        viewController.currentTraining = currentTraining
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func drawBarRect(imageView: UIImageView){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 174, height: 424))
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(Colors.creamCityCream.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(0.5)
            
            let offset: CGFloat = 12
            
            let barRectangle  = CGRect(x:offset, y:offset, width: 150, height: 400)
            ctx.cgContext.addRect(barRectangle)
            ctx.cgContext.setShadow(offset: CGSize.init(width: 0, height: 0), blur: 10)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            ctx.cgContext.addLines(between: [CGPoint(x:0+offset, y:200+offset), CGPoint(x:150+offset, y:200+offset)])
            ctx.cgContext.drawPath(using: .fillStroke)
            
        }
        imageView.image = img
        imageView.alpha = 0.9
        
    }
    
    static func drawBar(imageView: UIImageView){
        let renderer = UIGraphicsImageRenderer(size: CGSize(width:150, height: 10 ))
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(Colors.goodLandGreen.cgColor)
            ctx.cgContext.setShadow(offset: CGSize.init(width: 0, height: 0), blur: 10)
            
            let offset: CGFloat = 12
            
            let outerRectangle = CGRect(x: 0, y: 0, width: 150, height: 10)
            ctx.cgContext.addRect(outerRectangle)
            ctx.cgContext.drawPath(using: .fill)
        }
        imageView.image = img
    }
    
    func setBarPosition(magnitude: CGFloat, angle: CGFloat) {
        if self.flexion{
            self.pointY.constant = -147.5 * magnitude * sin(-angle)
        }else{
            self.pointX.constant = 147.5 * magnitude * cos(angle)
        }
        self.view.layoutIfNeeded()
        
    }
    
    
}
