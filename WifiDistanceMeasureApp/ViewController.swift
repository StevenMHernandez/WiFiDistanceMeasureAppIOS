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


class ViewController: UIViewController, StreamDelegate, GCDAsyncUdpSocketDelegate, ChartViewDelegate, BluetoothRssiDelegate {
    
    @IBOutlet weak var actualLineChart: UpdatableLineChartView!
    @IBOutlet weak var rssiLineChart: UpdatableLineChartView!
    @IBOutlet weak var accuracyLineChart: UpdatableLineChartView!
    
    var socket: GCDAsyncUdpSocket?
    
    var bluetoothRssiService = BluetoothRssiService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCharts()

        bluetoothRssiService.delegate = self
        bluetoothRssiService.setupBLE()
        
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
        setup(chart: self.actualLineChart, label: "Encoder Position")
        setup(chart: self.rssiLineChart, label: "RSSI Value")
        setup(chart: self.accuracyLineChart, label: "Accuracy")
    }
    
    func setup(chart: UpdatableLineChartView, label: String) {
        let setData: LineChartDataSet = LineChartDataSet(entries: [ChartDataEntry](), label: label)
        setData.drawCirclesEnabled = false
        setData.lineWidth = 2
        setData.axisDependency = .right
        setData.colors = [.blue]

        chart.data = LineChartData(dataSets: [setData])
        chart.updateTimeInterval = 0.025
        chart.threshold = 10000
        chart.extraLeftOffset = -30
        chart.minOffset = 0
        chart.leftAxis.drawLabelsEnabled = false
        chart.legend.drawInside = true
        chart.rightAxis.labelPosition = .insideChart
        chart.legend.drawInside = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.xAxis.drawLabelsEnabled = false
        chart.drawBordersEnabled = false
        chart.xAxis.drawAxisLineEnabled = false
        chart.delegate = self
        chart.start()
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let str = String(decoding: data, as: UTF8.self)
        let val = str.split(separator: "\n")[0]
        print(val)
        self.actualLineChart.addData(Double(val)!)
    }
    
    func bluetoothRssi(value: Double) {
        self.rssiLineChart.lastTime = value
        self.rssiLineChart.addData(value)
    }

    @IBAction func onSaveDataButtonPressed(_ sender: Any) {
        // TODO:
        print("send mail. . .")
    }
}

