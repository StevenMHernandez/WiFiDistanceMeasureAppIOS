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
        let val = str.split(separator: "\n")[0]
        self.delegate.udpEncoder(value: Double(val)!)
    }
}
