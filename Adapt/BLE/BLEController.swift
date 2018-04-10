//
//  BLEController.swift
//  Target_MB
//
//  Created by Timmy Gouin on 12/13/17.
//  Copyright © 2017 Timmy Gouin. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreData

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class BLEController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //CoreBluetooth Properties
    var centralManager:CBCentralManager!
    var sensorTile:CBPeripheral?
    static var shouldAutoconnect = true
    static var MAX_VALUE: Double = 655000000.0
    static var PERIPHERAL_UUID = "peripheral_uuid"
    static var SERVICE_UUID = "00000000-0001-11E1-9AB4-0002A5D5C51B"
    //static var CHARACTERISTIC_UUID = "00E00000-0001-11E1-AC36-0002A5D5C51B"
    //static var CHARACTERISTIC_UUID = "00000080-0001-11E1-AC36-0002A5D5C51B" //for WeSU
    static var CHARACTERISTIC_UUID = "00000100-0001-11E1-AC36-0002A5D5C51B" //for SensorTile
    var serviceUUID = CBUUID(string: BLEController.SERVICE_UUID)
    var characteristicUUID = CBUUID(string: BLEController.CHARACTERISTIC_UUID)
    var state:String?
    var max: Int32 = 0
    
    var sensorTileName = "SensorTile"
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let nc = NotificationCenter.default
        if let savedPeripheralUUID = UserDefaults.standard.string(forKey: BLEController.PERIPHERAL_UUID){
            if (BLEController.shouldAutoconnect && peripheral.identifier.uuidString == savedPeripheralUUID) {
                self.connect(peripheral: peripheral)
                nc.post(name:Notification.Name(rawValue:"SavedDeviceConnecting"), object: nil)
            }
        }
        nc.post(name:Notification.Name(rawValue:"DeviceFound"), object: peripheral)
        //        if let name = peripheral.name {
        //            print("\(name)")
        //            if name == "WeSU" {
        //                sensorTile = peripheral
        //                guard let unwrappedPeripheral = sensorTile else { return }
        //                unwrappedPeripheral.delegate = self
        //                centralManager.connect(unwrappedPeripheral, options: nil)
        //            }
        //        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //TODO: save peripheral for auto connect
        let defaults = UserDefaults.standard
        defaults.set(peripheral.identifier.uuidString, forKey: BLEController.PERIPHERAL_UUID)
        let appDelegate = UIApplication.shared.delegate
        
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                guard let unwrappedPeripheral = sensorTile else { return }
                unwrappedPeripheral.setNotifyValue(true, for: characteristic)
                return
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if var value = characteristic.value {
            let data = NSData(data: value)
            //print("Sensor data: \(value.hexEncodedString())")
            if value.count == 20 {
                //parse values
                var timestamp:UInt16 = 0
                data.getBytes(&timestamp, range: NSMakeRange(0, 2))
                
                var yaw:Int16 = 0
                data.getBytes(&yaw, range: NSMakeRange(2, 2))
                
                var pitch:Int16 = 0
                data.getBytes(&pitch, range: NSMakeRange(4, 2))
                
                var roll:Int16 = 0
                data.getBytes(&roll, range: NSMakeRange(6, 2))
                
                //var qS:Int32 = 0
                //data.getBytes(&qS, range: NSMakeRange(14, 4))
                //                var dQi = Double(qI)
                //                var dQj = Double(qJ)
                //                var dQk = Double(qK)
                //                var dQs = Double(qS)
                //                if (qI > max) {
                //                    max = qI
                //                }
                //                if (qJ > max) {
                //                    max = qJ
                //                }
                //                if (qK > max) {
                //                    max = qK
                //                }
                //                if (qS > max) {
                //                    max = qS
                //                }
                var dYaw = Double(yaw)
                var dPitch = Double(pitch)
                var dRoll = Double(roll)
                //print("MAX \(max)")
                //let normalized = sqrt(dQi * dQi + dQj * dQj + dQk * dQk)
                dYaw /= 100.0
                dPitch /= 100.0
                dRoll /= 100.0
                //                dQi /= BLEController.MAX_VALUE
                //                dQj /= BLEController.MAX_VALUE
                //                dQk /= BLEController.MAX_VALUE
                //                dQs /= BLEController.MAX_VALUE
                //                print("Timestamp: \(timestamp) Qi: \(dQi) Qj: \(dQj) Qk: \(dQk) Qs: \(dQs)")
                //print("Timestamp: \(timestamp) Yaw: \(dYaw) Pitch: \(dPitch) Roll: \(dRoll)")
                //let quaternion = Quaternion(x: dQi, y: dQj, z: dQk, w: dQs)
                //let euler = Utilities.quatToEuler(quat: quaternion)
                let euler = Euler(yaw: dYaw, pitch: dPitch, roll: dRoll)
                //print("Euler Angles: yaw: \(euler.yaw) pitch: \(euler.pitch) roll: \(euler.roll)")
                let nc = NotificationCenter.default
                //nc.post(name:Notification.Name(rawValue:"DeviceData"), object: quaternion)
                nc.post(name:Notification.Name(rawValue:"DeviceData"), object: euler)
                
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            state = "Bluetooth on this device is powered on."
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off."
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            state = "The state of the BLE Manager is unknown."
        }
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func connect(peripheral: CBPeripheral) {
        stopScan()
        BLEController.shouldAutoconnect = true
        sensorTile = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
}




