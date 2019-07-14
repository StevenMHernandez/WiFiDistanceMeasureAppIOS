//
//  DataCollectorService.swift
//  WifiDistanceMeasureApp
//
//  Created by Steven Hernandez on 7/12/19.
//  Copyright © 2019 MoWiNG Lab. All rights reserved.
//

import Foundation

class DataCollectorService {
    var fileURL: URL!
    
    init() {
        let timestamp = Date().millisecondsSince1970()!
        fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(timestamp).csv")
    }
    
    func newData(data: String) {
        if let outputStream = OutputStream(url: fileURL, append: true) {
            outputStream.open()
            let bytesWritten = outputStream.write(data, maxLength: data.count)
            if bytesWritten < 0 { print("write failure") }
            outputStream.close()
        } else {
            print("Unable to open file")
        }
    }
    
}
