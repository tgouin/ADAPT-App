//
//  DeviceViewController.swift
//  Target_MB
//
//  Created by Timmy Gouin on 1/7/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEDevicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var peripherals: [CBPeripheral] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let cancelBarButton = UINavigationItem()
        cancelBarButton.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelPressed))
        navBar.setItems([cancelBarButton], animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let peripheral = appDelegate.bleController.sensorTile {
            appDelegate.bleController.centralManager.cancelPeripheralConnection(peripheral)
        }
        BLEController.shouldAutoconnect = false
        appDelegate.bleController.startScan()
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"DeviceFound"),
                       object:nil, queue:nil) {
                        notification in
                        if let peripheral = notification.object as? CBPeripheral {
                            if let name = peripheral.name {
                                var found = false
                                for periph in self.peripherals {
                                    if periph.name == name {
                                        found = true
                                        break
                                    }
                                }
                                if !found {
                                    self.peripherals.append(peripheral)
                                    self.tableView.reloadData()
                                }
                            }
                        }
        }
    }
    
    @objc func cancelPressed(_ sender: UIBarButtonItem ) {
        performSegue(withIdentifier: "unwindToDashboard", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return DeviceCell()
        let reuse = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        var cell: DeviceCell
        if let deviceCell = reuse as? DeviceCell {
            cell = deviceCell
        } else {
            cell = DeviceCell()
        }
        guard indexPath.row < peripherals.count else { return DeviceCell() }
        let peripheral = peripherals[indexPath.row]
        if let name = peripheral.name {
            cell.deviceName.text = name
        }
        cell.deviceAddress.text = peripheral.identifier.uuidString
        if let rssi = peripheral.rssi {
            cell.deviceRSSI.text = "\(rssi)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < peripherals.count else { return }
        let peripheral = peripherals[indexPath.row]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.bleController.connect(peripheral: peripheral)
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "unwindToMain", sender: nil)
    }
    
}

