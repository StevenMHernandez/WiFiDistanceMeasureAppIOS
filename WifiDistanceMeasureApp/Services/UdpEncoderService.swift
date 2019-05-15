//
//  UdpEncoderService.swift
//  WifiDistanceMeasureApp
//
//  Created by Steven Hernandez on 5/14/19.
//  Copyright © 2019 MoWiNG Lab. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public protocol UdpEncoderServiceDelegate: NSObjectProtocol {
    func udpEncoder(value: Double)
    func udpEncoder(distance: Double)
}

class UdpEncoderService: NSObject, GCDAsyncUdpSocketDelegate {
    var delegate: UdpEncoderServiceDelegate!
    var socket: GCDAsyncUdpSocket?
    
    func setupUDP() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket?.bind(toPort: 4201)
            try socket?.beginReceiving()
        } catch let err {
            print("Error: ", err)
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let str = String(decoding: data, as: UTF8.self)
        let value = Double(str.split(separator: "\n")[0])!
        let distance = self.mapEncoderToDistance(value: value)
        self.delegate.udpEncoder(value: value)
        self.delegate.udpEncoder(distance: distance)
    }
    
    func mapEncoderToDistance(value: Double) -> Double {
        let distances = [
            0.0,   // encoder ->   0cm
            23.0,  // encoder ->  25cm
            48.0,  // encoder ->  50cm
            73.0,  // encoder ->  75cm
            99.0,  // encoder -> 100cm
            125.0, // encoder -> 125cm
            152.0, // encoder -> 150cm
            180.0, // encoder -> 175cm
            208.0, // encoder -> 200cm
            238.0, // encoder -> 225cm
            268.0, // encoder -> 250cm
            300.0, // encoder -> 275cm
            331.0, // encoder -> 300cm
            365.0, // encoder -> 325cm
            401.0, // encoder -> 350cm
            437.0, // encoder -> 375cm
        ]
        
        var d = 0.0
        
        for i in 0..<(distances.count - 1) {
            if value >= distances[i] && value < distances[i+1] {
                let theRange = (distances[i+1] - distances[i])
                let percentageOfRange = (value - distances[i]) / theRange
                let minCm = (Double(i) * 25.0)
                d = (minCm + (25.0 * percentageOfRange)) / 100.0
            }
        }
        
        return d
    }
}
