//
//  ViewController.swift
//  WifiDistanceMeasureApp
//
//  Created by Steven Hernandez on 5/12/19.
//  Copyright © 2019 MoWiNG Lab. All rights reserved.
//

import UIKit
import Charts


class ViewController: UIViewController, StreamDelegate, ChartViewDelegate, BluetoothRssiDelegate, UdpEncoderServiceDelegate {
    
    @IBOutlet weak var actualLineChart: UpdatableLineChartView!
    @IBOutlet weak var rssiLineChart: UpdatableLineChartView!
    @IBOutlet weak var accuracyLineChart: UpdatableLineChartView!
    
    var bluetoothRssiService = BluetoothRssiService()
    var udpEncoderService = UdpEncoderService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCharts()

        bluetoothRssiService.delegate = self
        bluetoothRssiService.setupBLE()
        
        udpEncoderService.delegate = self
        udpEncoderService.setupUDP()
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
    
    func bluetoothRssi(value: Double) {
        self.rssiLineChart.lastTime = value
        self.rssiLineChart.addData(value)
    }
    
    func udpEncoder(value: Double) {
        self.actualLineChart.lastTime = value
        self.actualLineChart.addData(value)
    }

    @IBAction func onSaveDataButtonPressed(_ sender: Any) {
        // TODO:
        print("send mail. . .")
    }
}

