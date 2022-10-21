//
//  XSAPI.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import Alamofire
import AdSupport

// 接口文档: http://192.168.50.81:9908/doc.html
let IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
let kVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String ?? "Unknown"//app版本
let deviceName = UIDevice.current.systemName
let deviceModel = UIDevice.current.model // 手机型号

let commonHeaders:HTTPHeaders = HTTPHeaders.init([
    "driveCode": IDFA,
    "driveType": "1",
    "ip" : "1.1.1.1",
    "userId" : String(currentUser?.id ?? 0) ,
    "timestamp" : Date().milliStamp,
    "driveName": deviceName + deviceModel,
    "version": kVersion,
])

struct XSUrl {
    var path: String
    var params:Dictionary<String, Any>?
    var method:HTTPMethod
    
    init(path:String , methed:HTTPMethod = .get) {
        self.path = path
        self.method = methed
    }
    init(path:String) {
        self.path = path
        self.method = .get
    }
}

let kHttpBaseURL: String = "https://mobile.xspace.ga"
//let kHttpBaseURL: String = "http://192.168.1.104:8081"
let kPrivacyURL = kHttpBaseURL + "/privacy"
let kServiceURL = kHttpBaseURL + "/server"
let kPaymentURL = kHttpBaseURL + "/server"
let kAboutURL = kHttpBaseURL + "/about"

//let BaseURL = "http://114.115.251.191:9908"
let BaseURL = "https://xspace.ga"
//let BaseURL = "http://192.168.1.104:9909"

struct XSAPI {
    // 注销用户
    let cancelUser = XSUrl.init(path: "/api/login/cancellation")
    let getBannerInfo = XSUrl(path: "/api/banner/v1/info")
    let loginOut = XSUrl(path: "/api/login/exit")
    //上传IP
    let uploadIP = XSUrl(path: "/api/login/getIp")
    let getUserInfo = XSUrl(path: "/api/login/userInfo")
    let getLineList = XSUrl(path: "/api/line/v1/list")
    let getConfigInfo = XSUrl(path: "/api/config/info")
    let getEducationInfo = XSUrl(path: "/api/education/info")
    //手机号登录
    let phoneLogin = XSUrl(path: "/api/login/phoneAccount", methed: .post)
    //发送验证码
    let sendCode = XSUrl(path: "/api/login/sendCode", methed: .post)
    let createOrder = XSUrl(path: "/api/order/createOrder", methed: .post)
    let checkCode = XSUrl(path: "/api/login/checkCode", methed: .post)
    
}

let api = XSAPI()
