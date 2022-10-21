//
//  XSNetworkSpeed.swift
//  xspace
//
//  Created by Lendo on 2022/8/16.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation

let kNetworkDownloadSpeedNotification = "NetworkDownloadSpeedNotificationKey"
let kNetworkUploadSpeedNotification = "NetworkUploadSpeedNotificationKey"

class XSNetworkSpeed: NSObject {
    var downloadSpeed:String = "__"
    var uploadSpeed:String = "__"
    var timer:Timer?
    
    override init() {
        super.init()
        
    }
    
    func startNetworkSpeedMonitor() {
        if timer == nil {
            timer = Timer(timeInterval: 1, target: self, selector: #selector(checkNetworkSpeed), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
            timer?.fire()
        }
    }
    
    func stopNetworkSpeedMonitor() {
        if timer != nil , timer!.isValid {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func checkNetworkSpeed() {
        
    }
    
}
