//
//  UpdatableLineChartView.swift
//  WifiDistanceMeasureApp
//
//  Created by Steven Hernandez on 5/13/19.
//  Copyright © 2019 MoWiNG Lab. All rights reserved.
//

import Foundation
import Charts

// @See https://stackoverflow.com/a/49571718
extension Date {
    
    func millisecondsSince1970() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    init(millis: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
        self.addTimeInterval(TimeInterval(Double(millis % 1000) / 1000 ))
    }
    
}

class UpdatableLineChartView: LineChartView {
    var timer: Timer?
    var updateTimeInterval = 1.0
    var threshold = 1000.0
    var startMillis = Date().millisecondsSince1970()
    var lastTime = 0.0
    
    func start() {
        self.timer = Timer.scheduledTimer(timeInterval: self.updateTimeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction() {
        #if targetEnvironment(simulator)
            lastTime += ceil(Double(arc4random()) / Double(UINT32_MAX) * 10) - 5
        #endif
        self.addData(lastTime)
    }
    
    func addData(_ x: Double) {
        let diff = Double(Date().millisecondsSince1970()! - self.startMillis!)
        self.data!.addEntry(ChartDataEntry(x: Double(diff), y: x), dataSetIndex: 0)
        
        self.xAxis.axisMinimum = diff - self.threshold
        

        if diff > self.threshold {
            for i in 0..<self.data!.dataSets.count {
                removeOldDataFor(datasetIndex: i)
            }
        }
        self.notifyDataSetChanged()
    }
    
    func removeOldDataFor(datasetIndex: Int) {
        let dset = self.data!.getDataSetByIndex(datasetIndex)!
        if let e = dset.entryForIndex(0), e.x < (Double(Date().millisecondsSince1970()) - self.threshold) {
            _ = dset.removeEntry(dset.entryForIndex(0)!)
        }
    }
}
