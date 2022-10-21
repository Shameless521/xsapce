//
//  AppDelegate.swift
//  xspace
//
//  Created by dcloud on 2022/8/1.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isForceLandscape: Bool = false
    var isForcePortrait: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        XSUser.unArchived()
        XSLineModel.unArchived()
        
        UMConfigure.initWithAppkey("632d16cb88ccdf4b7e36a410", channel: "App Store")
//        UMCommonSwift.setLogEnabled(bFlag: false)
        
        let vc = XSBaseNavViewController(rootViewController: XSMainViewController())
        
        self.window?.backgroundColor = .white
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            
        if (isForceLandscape) {
            //这里设置允许横屏的类型
            return .landscapeRight
        }else if (isForcePortrait){
            return .portrait
        }

        return .portrait
    }
}

