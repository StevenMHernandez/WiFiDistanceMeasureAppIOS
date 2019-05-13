//
//  ViewController.swift
//  WifiDistanceMeasureApp
//
//  Created by Steven Hernandez on 5/12/19.
//  Copyright © 2019 MoWiNG Lab. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import Charts


class ViewController: UIViewController, StreamDelegate, GCDAsyncUdpSocketDelegate, ChartViewDelegate {
    
    @IBOutlet weak var actualLineChart: UpdatableLineChartView!
    var socket: GCDAsyncUdpSocket?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCharts()
        
        #if targetEnvironment(simulator)
            socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            do {
                try socket?.bind(toPort: 4201)
                try socket?.beginReceiving()
            } catch let err {
                print("Error: ", err)
            }
        #endif
    }
    
    func setupCharts() {
        // Setup the line chart view
        self.actualLineChart.delegate = self
        let set: LineChartDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: "Encoder Position")
        set.drawCirclesEnabled = false
        self.actualLineChart.data = LineChartData(dataSets: [set])
        self.actualLineChart.updateTimeInterval = 0.025
        self.actualLineChart.threshold = 10000
        self.actualLineChart.start()
        self.actualLineChart.extraLeftOffset = 0.0
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let str = String(decoding: data, as: UTF8.self)
        let val = str.split(separator: "\n")[0]
        print(val)
        self.actualLineChart.addData(Double(val)!)
    }
}

