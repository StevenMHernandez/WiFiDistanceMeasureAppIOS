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


// @See https://stackoverflow.com/a/49571718
// This seems to have been removed from swift at some point
extension Date {

    func millisecondsSince1970() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    init(millis: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
        self.addTimeInterval(TimeInterval(Double(millis % 1000) / 1000 ))
    }
    
}

class ViewController: UIViewController, StreamDelegate, GCDAsyncUdpSocketDelegate, ChartViewDelegate {
    
    @IBOutlet weak var actualLineChart: LineChartView!
    var socket: GCDAsyncUdpSocket?
    var startMillis = Date().millisecondsSince1970()
    var plotTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCharts()
        
        self.plotTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket?.bind(toPort: 4201)
            try socket?.beginReceiving()
        } catch let err {
            print("Error: ", err)
        }
    }
    
    @objc func timerAction() {
        let diff = Date().millisecondsSince1970()! - self.startMillis!
        actualLineChart.data!.addEntry(ChartDataEntry(x: Double(diff), y: lastTime), dataSetIndex: 0)
        actualLineChart.notifyDataSetChanged();
    }
    
    func setupCharts() {
        // Setup the line chart view
        self.actualLineChart.delegate = self
        let set: LineChartDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: "RSSI")
        set.drawCirclesEnabled = false
        self.actualLineChart.data = LineChartData(dataSets: [set])
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let str = String(decoding: data, as: UTF8.self)
        let val = str.split(separator: "\n")[0]
        print(val)
        addDataPoint(value: Double(val)!, datasetIndex: 0)
    }
    
    var lastTime = 0.0
    
    func addDataPoint(value: Double, datasetIndex: Int) {
        lastTime = value
        if self.actualLineChart.data != nil {
            let diff = Date().millisecondsSince1970()! - self.startMillis!
            
            self.actualLineChart.data!.addEntry(ChartDataEntry(x: Double(diff), y: value), dataSetIndex: datasetIndex)
            
            actualLineChart.notifyDataSetChanged();
            
//            self.actualLineChart.xAxis.axisMinimum = Double(diff-DA_BIG_THRESHOLD)
            
//            if Int(floor(Double(arc4random()) / Double(UINT32_MAX) * 10)) == 0 {
//                if diff > DA_BIG_THRESHOLD {
//                    //                    print("💨 spring cleaning\(diff - DA_BIG_THRESHOLD)")
//                    for i in 0..<self.actualLineChart.data!.dataSets.count {
//                        removeOldDataFor(datasetIndex: i)
//                    }
//                    actualLineChart.notifyDataSetChanged();
//                }
//            }
        }
    }
}

