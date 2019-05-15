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
    
    @IBOutlet weak var actualDistanceLineChart: UpdatableLineChartView!
    @IBOutlet weak var rssiLineChart: UpdatableLineChartView!
    @IBOutlet weak var encoderPositionLineChart: UpdatableLineChartView!
    
    var bluetoothRssiService = BluetoothRssiService()
    var udpEncoderService = UdpEncoderService()
    var mailService = MailService()
    
    var timer: Timer?
    var dataList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCharts()
        setupTimer()

        bluetoothRssiService.delegate = self
        bluetoothRssiService.setupBLE()
        
        udpEncoderService.delegate = self
        udpEncoderService.setupUDP()
    }
    
    func setupCharts() {
        // Setup the line chart view
        setup(chart: self.actualDistanceLineChart, label: "Actual Distance (m)")
        setup(chart: self.rssiLineChart, label: "RSSI Value")
        setup(chart: self.encoderPositionLineChart, label: "Encoder Position")
    }

    func setupTimer() {
        self.dataList.append("time,uuid,encoder,rssi\n")
        self.timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    @objc func timerAction() {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        self.dataList.append("\(Date().millisecondsSince1970()!),\(deviceId),\(self.actualDistanceLineChart.lastTime),\(self.rssiLineChart.lastTime)\n")
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
    
    func udpEncoder(distance: Double) {
        self.actualDistanceLineChart.lastTime = distance
        self.actualDistanceLineChart.addData(distance)
    }
    
    func udpEncoder(value: Double) {
        self.encoderPositionLineChart.lastTime = value
        self.encoderPositionLineChart.addData(value)
    }

    @IBAction func onSaveDataButtonPressed(_ sender: Any) {
        self.mailService.send(data: dataList, viewController: self)
    }
}

