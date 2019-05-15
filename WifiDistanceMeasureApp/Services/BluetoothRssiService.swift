//
//  BluetoothRSSIService.swift
//  WifiDistanceMeasureApp
//
//  Created by Steven Hernandez on 5/14/19.
//  Copyright © 2019 MoWiNG Lab. All rights reserved.
//

import Foundation
import RxSwift
import CoreBluetooth
import RxBluetoothKit

public protocol BluetoothRssiDelegate: NSObjectProtocol {
    func bluetoothRssi(value: Double)
}

class BluetoothRssiService {
    let SERVICE_UUID_STRING = "D4627123-5555-9999-73B7-FEE516F96870"
    var centralManager: CentralManager! = CentralManager(queue: .main)
    var peripheralManager: PeripheralManager! = PeripheralManager(queue: .main)
    var centralManagerObserver: Observable<ScannedPeripheral>!
    var bleService:CBMutableService!
    var disposablePeripheralScanner: Disposable!
    var disposablePeripheralManagerAdvertise: Disposable!
    var peripheralDatasetIndex = [UUID: Int]()
    var peripheralConnected = [UUID: Int]()
    var delegate: BluetoothRssiDelegate!
    
    func setupBLE() {
        let bleServiceCBUUID = CBUUID(string: SERVICE_UUID_STRING)
        
        self.bleService = CBMutableService(type: bleServiceCBUUID, primary: true)
        
        disposablePeripheralManagerAdvertise = self.peripheralManager.observeState()
            .startWith(self.peripheralManager.state)
            .filter { $0 == .poweredOn }
            .take(1)
            .flatMap { _ in self.peripheralManager.add(self.bleService) }
            .flatMap { _ in self.peripheralManager.startAdvertising([
                CBAdvertisementDataLocalNameKey: "BLELOC",
                CBAdvertisementDataServiceUUIDsKey : [self.bleService.uuid]
                ]) }
            .subscribe({ _ in
                print("advertising!")
            })
        
        disposablePeripheralScanner = self.centralManager.observeState()
            .startWith(centralManager.state)
            .filter { $0 == .poweredOn }
            .subscribe({ _ in
                print("powered on")
                
                let _ = self.centralManager.observeDisconnect()
                    .subscribe({ event in
                        if let (peripheral, _) = event.element {
                            let uuid = peripheral.identifier
                            if self.peripheralConnected[uuid] != nil {
                                self.peripheralConnected[uuid] = nil
                            }
                            print("disconnected", uuid)
                        }
                    })
                
                _ = self.centralManager.scanForPeripherals(withServices: [bleServiceCBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)])
                    .subscribe(onNext: { scannedPeripheral in
                        if scannedPeripheral.rssi != 127 {
                            self.delegate.bluetoothRssi(value: Double(truncating: scannedPeripheral.rssi))
                        }
                    })
            })
    }
}
