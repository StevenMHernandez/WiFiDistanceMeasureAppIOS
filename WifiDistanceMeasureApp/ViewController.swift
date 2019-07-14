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
    var dataCollectorService = DataCollectorService()
    
    var timer: Timer?

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
        self.dataCollectorService.newData(data: "time,uuid,encoder,distance,rssi\n")
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    @objc func timerAction() {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        self.dataCollectorService.newData(data: "\(Date().millisecondsSince1970()!),\(deviceId),\(self.encoderPositionLineChart.lastTime),\(self.actualDistanceLineChart.lastTime),\(self.rssiLineChart.lastTime)\n")
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
//        self.rssiLineChart.addData(value)
        
        let lastIndex = myList.count - 1
        
        
        // Rolling average of the previous `k` elements
        var rolling_mean = value
        var my_diff = 0.0

//        let k = min(lastIndex, 15)
//        if k > 0 {
//            rolling_mean = 0.0
//            for i in 0...k-1 {
//                rolling_mean += self.myList[lastIndex - i]
//            }
//            print(rolling_mean)
//            rolling_mean = rolling_mean / Double(k)
//            my_diff = rolling_mean - self.myList[lastIndex]
//        }

        self.myList.append(value)
        self.myRollingList.append(rolling_mean)
        self.myDiffList.append(my_diff)
//        print(rolling_mean, lastIndex, k)
        self.rssiLineChart.addData(rolling_mean)
//        let model = test_model()
//        let my_num = 1
//        let input = try? MLMultiArray(shape:[NSNumber(value: my_num)], dataType: .double)
////        print(lastIndex)
//        if lastIndex > my_num {
//            for i in 0...(my_num-1) {
//                input![i] = NSNumber(value: myDiffList[lastIndex - i])
//            }
//    //        input![0] = NSNumber(value: value)
////            let output = try? model.prediction(input: input!)
////    //        print(model.prediction(input: [-24.0]))
////            if let y = output {
//////                print(y.output)
////                var best_value = -99.0
////                var best_key = "none"
////                for k in y.output.keys {
////                    if y.output[k]! > best_value {
////                        best_value = y.output[k]!
////                        best_key = k
////                    }
////                }
////
////                statusLabel.text = best_key
////
////            }
//        }
    }
    
    func udpEncoder(distance: Double) {
        self.actualDistanceLineChart.lastTime = distance
        self.actualDistanceLineChart.addData(distance)
    }
    
    func udpEncoder(value: Double) {
        self.encoderPositionLineChart.lastTime = value
        self.encoderPositionLineChart.addData(value)
    }
}

