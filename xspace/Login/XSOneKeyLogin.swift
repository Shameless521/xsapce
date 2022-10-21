//
//  XSOneKeyLoginVC.swift
//  xspace
//
//  Created by Lendo on 2022/8/9.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import NTESQuickPass
import NTESBaseComponent
import CryptoSwift
import MapKit

let oneKeyLogin = XSOneKeyLogin()
class XSOneKeyLogin: NSObject {
    var accessToken:String = ""
    var token:String = ""
    var phoneNum:String = ""
    var currentVC:UIViewController?
    var isSelect:Bool = false
    let otherLoginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("其他登录方式", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return btn
    }()
    
    let manager = NTESQuickLoginManager.sharedInstance()
    func register() {
        manager.register(withBusinessID: "df65a0e49be147339f02c838ad6f4ae1")
        manager.timeoutInterval = 3000
        otherLoginBtn.addTarget(self, action: #selector(otherLoginAction), for: .touchUpInside)
    }
    
    @objc func otherLoginAction() {
        self.currentVC?.navigationController?.pushViewController(XSLoginViewController(), animated: true)
    }
    
    func shouldQuickLogin() -> Bool {
        return manager.shouldQuickLogin()
    }

    // MARK: - 易盾SDK
    func getPhoneNumber(currentVC:UIViewController) {
        self.currentVC = currentVC
        
        guard self.shouldQuickLogin() else {
            // 无法一键登录, 直接手机号登录
            self.currentVC?.navigationController?.pushViewController(XSLoginViewController(), animated: true)
            return
        }
        
        // 需要加个网络检测
        manager.getPhoneNumberCompletion { [self] dic in
            let success = dic["success"] as! Bool
            if success {
                self.token = dic["token"] as! String
                manager.setupModel(getNTESModel(vc: currentVC))
                // 拉起授权页面
                manager.cucmctAuthorizeLoginCompletion {[self] resultDic in
                    let success = resultDic["success"] as! Bool
                    if success {
                        print("取号成功")
                        self.accessToken = (resultDic["accessToken"] as? String) ?? ""
                        self.loginAction()

                    } else {
                        currentVC.navigationController?.topViewController?.showMessage(message: "无法自动获取本机号码")
                    }
                }
            } else {
                self.currentVC!.navigationController?.showMessage(message: "请选择其它登录方式")
            }
        }
    }
    
    
@objc func back() {
    self.currentVC?.navigationController?.popViewController(animated: true)
}
    
    func getNTESModel(vc:UIViewController) -> NTESQuickLoginModel {
        let model = NTESQuickLoginModel()
        model.currentVC = vc
        model.presentDirectionType = NTESPresentDirection.push
        model.authWindowPop = .fullScreen
        model.faceOrientation = .portrait
        model.bgImage = UIImage(named: "bg_login")!
        model.contentMode = .scaleToFill
        model.modalPresentationStyle = .fullScreen
        model.modalTransitionStyle = .coverVertical
        
        model.customViewBlock = {[self]
         custom in
            let btn = UIButton(frame: CGRect(x: 0, y: StatusBarHeight, width: 44, height: 44))
            btn.addTarget(self, action:  #selector(self.back), for: .touchUpInside)
            btn.setImage(UIImage(named: "btn_log_arrow"), for: .normal)
            custom?.addSubview(btn)
            otherLoginBtn.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: kRealScale(454+64), width: 100, height: 20)
            custom?.addSubview(otherLoginBtn)
        }
        
        model.statusBarStyle = .lightContent
        model.navBarHidden = true
        model.navBgColor = .clear
        model.navReturnImg = UIImage(named: "btn_log_arrow")!
        
        model.logoImg = UIImage(named: "login_logo")!
        model.logoWidth = kRealScale(105)
        model.logoHeight = kRealScale(105)
        model.logoHidden = false
        model.logoOffsetTopY = kRealScale(149)
        
        model.numberColor = .white
        model.numberFont = UIFont.systemFont(ofSize: 22, weight: .regular)
        model.numberHeight = 31
        model.numberOffsetTopY = kRealScale(310+44)
        
        // 认证品牌
        model.brandColor = colorCCC
        model.brandOffsetTopY = kRealScale(345+44)
        
        // 登录按钮
        model.logBtnText = "本机号码一键登录"
        model.logBtnTextColor = .white
        model.logBtnTextFont = UIFont.systemFont(ofSize: 15)
        model.logBtnRadius = 22
        model.logBtnHeight = 44
        model.logBtnOffsetTopY = kRealScale(402+44)
        model.startPoint = CGPoint(x: 0, y: 0.5)
        model.endPoint = CGPoint(x:1,y:0.5)
        model.colors = [colorYellew.cgColor,colorOrange.cgColor]
        
        // 隐私协议
        model.uncheckedImg = UIImage(named: "btn_login")!
        model.checkedImg = UIImage(named: "btn_login_sel")!
        model.checkboxWH = 20
        model.appPrivacyText = "登录即同意《服务条款》和《隐私协议》，并授权星舰加速器获取手机号"
        model.appFPrivacyText = "服务条款"
        model.appFPrivacyURL = kServiceURL
        model.appSPrivacyText = "隐私协议"
        model.appSPrivacyURL = kPrivacyURL
        model.privacyColor = .white
        model.privacyFont = UIFont.systemFont(ofSize: 12)
        model.protocolColor = colorYellew2
        model.appPrivacyOriginTopMargin = UIScreen.main.bounds.height - kRealScale(80)
        model.loginActionBlock = {result in
        }
        model.checkActionBlock = { isChecked in
            self.isSelect = isChecked
        }
        
        return model
    }
    
    func loginAction() {
        guard self.isSelect else {
            self.currentVC!.navigationController?.hubHide()
            return
        }
        self.currentVC!.navigationController?.showHub()
        let params = ["accessToken":self.accessToken, "wyToken":self.token, "udid":IDFA ,"driveType": 0,"version":kVersion] as [String : Any]
        requestManger.request(url: api.phoneLogin , params: params) { [self] success, result in
            guard success else {
                self.currentVC!.navigationController?.showMessage(message: result.message)
                return
            }
            currentUser = XSUser(json: result.data)
            currentUser?.archived()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHadLoginNoticeName), object: nil, userInfo: nil)
            manager.clearPreLoginCache()
            self.currentVC!.navigationController?.popViewController(animated: true)
            self.currentVC!.navigationController?.showMessage(message: "登录成功")
        }
    }

}
