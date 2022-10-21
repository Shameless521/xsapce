//
//  GCDTimer.swift
//  CheeseLite
//
//  Created by Monks on 2021/8/5.
//

import Foundation
typealias ActionBlock = () -> ()

class GCDTimer : NSObject {
    static let share = GCDTimer()
    
    lazy var timerContainer = [String : DispatchSourceTimer]()
    
    /// 创建一个名字为name的定时
    ///
    /// - Parameters:
    ///  - name: 定时器的名字
    ///  - timeInterval: 时间间隔
    ///  - queue: 线程
    ///  - repeats: 是否重复
    ///  - action: 执行的操作
    func scheduledDispatchTimer(withName name:String?, timeInterval:Double, queue:DispatchQueue, repeats:Bool, action:@escaping ActionBlock ) {
        if name == nil {
            return
        }
        var timer = timerContainer[name!]
        if timer==nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
            timer?.resume()
            timerContainer[name!] = timer
        }
        timer?.schedule(deadline: .now(), repeating: timeInterval, leeway: .milliseconds(100))
        timer?.setEventHandler(handler: { [weak self] in
          action()
          if repeats==false {
            self?.destoryTimer(withName: name!)
          }
        })

    }


    /// 销毁名字为name的计时器
    ///
    /// - Parameter name: 计时器的名字
    func destoryTimer(withName name:String?) {
        let timer = timerContainer[name!]
        if timer == nil {
          return
        }
        timerContainer.removeValue(forKey: name!)
        timer?.cancel()
    }


    /// 检测是否已经存在名字为name的计时器
    ///
    /// - Parameter name: 计时器的名字
    /// - Returns: 返回bool值
    func isExistTimer(withName name:String?) -> Bool {
        if timerContainer[name!] != nil {
            return true
        }
        
        return false
    }
}
