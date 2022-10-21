//
//  XSMainViewController.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit
import RxCocoa
import RxSwift
import NetworkExtension

// MARK: - 选中线路显示的
class LineItem: UIView {
    let icon:UIImageView = {
        let imgv = UIImageView()
        imgv.layer.borderColor = UIColor.white.cgColor
        imgv.layer.borderWidth = 2
        imgv.layer.cornerRadius = 20
        imgv.layer.masksToBounds = true
        imgv.image = UIImage(named: "img_avatar_loading_def")
        return imgv
    }()
    
    let lineTitleBtn:rightImageBtn = {
        let obj = rightImageBtn()
        obj.bottomTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        obj.setTitle("国家", for: .normal)
        obj.setImage(UIImage.init(named: "btn_home_arrow_bold"), for: .normal)
        return obj
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(icon)
        self.addSubview(lineTitleBtn)
        icon.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalToSuperview().offset(-9)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        lineTitleBtn.snp.makeConstraints { make in
            make.top.equalTo(icon.snp_bottomMargin).offset(12)
            make.centerX.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - 主页面
class XSMainViewController: UIViewController {
    
    var manager = XSSpeedManage.shared()
    
    let bgHeaderImageV:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage.init(named: "img_home_map")
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
    let lineItem = LineItem()
    
    let bgline: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 1, alpha: 0.15)
        return view
    }()
    
    let downloadSpeed: SpeedView = {
        let view = SpeedView()
        view.speedTip.text = "下载速度"
        view.arrow.image = UIImage.init(named: "img_home_arrow_greed")
        return view
    }()
    
    let uploadSpeed: SpeedView = {
        let view = SpeedView()
        view.speedTip.text = "上传速度"
        view.arrow.image = UIImage.init(named: "img_home_arrow_red")
        return view
    }()
    
    let testSpeedBtn: rightImageBtn = {
        let btn = rightImageBtn()
        btn.layer.borderColor = UIColor.init(white: 1, alpha: 0.7).cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 20
        btn.setTitle("开始测速", for: .normal)
        btn.setImage(UIImage(named: "btn_home_arrow_bold"), for: .normal)
        return btn
    }()
    
    let slideBtn = XSSlideBtn(frame: CGRect(x: 0, y: 0, width: 98, height: 215))
    let mineVC = XSMineViewController()
    let mineViewWidth = kRealScale(300.0)
    let maskView:UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = true
        return v
    }()
    
    let mineBtn: TopImageBtn = {
        let btn = TopImageBtn()
        btn.bottomTitle.text = "我的"
        btn.icon.image = UIImage(named: "btn_home_mine")
        return btn
    }()

    let memberBtn: TopImageBtn = {
        let btn = TopImageBtn()
        btn.bottomTitle.text = "会员"
        btn.icon.image = UIImage(named: "btn_home_member")
        return btn
    }()
    
    // 不可点击的灰色背景
    let hubView: UIView = {
        let hub = UIView()
        hub.frame = UIScreen.main.bounds
        hub.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
        return hub
    }()
    
    let testSpeedView = XSTestSpeedView(frame: CGRect(x: 0, y: 0, width: 345, height: 345))
    
    var bannerList: Array<XSBanner> = Array()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: manager.manager.connection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        requestLine()
        prepareUI()
        checkStateAction()
        getUserInfoData()
        
        self.navigationController?.isNavigationBarHidden = true
        // 添加蒙板, 左滑展示我的页面
        self.maskView.frame = UIScreen.main.bounds
        self.maskView.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
        view.addSubview(self.maskView)
        self.maskView.isHidden = true
        let tap = UITapGestureRecognizer()
        self.maskView.addGestureRecognizer(tap)
        let _ = tap.rx.event.subscribe { OnNext in
            self.closeMineVC()
        }
        self.inputViewController?.addChild(self.mineVC)
        self.mineVC.view.frame = CGRect(x: -mineViewWidth, y: 0, width: mineViewWidth, height: UIScreen.main.bounds.height)
        self.view.addSubview(self.mineVC.view)

        
        // 点击开始测速
        let _ = testSpeedBtn.rx.tap.asObservable().subscribe { onNext in
            self.showSpeedAlert()
        }
        
        // 关闭测速
        let _ = testSpeedView.cancelBtn.rx.tap.asObservable().subscribe { onNext in
            self.closeSpeedAlert()
        }
        
        // 点击选择的线路
        let _ = lineItem.lineTitleBtn.rx.tap.asObservable().subscribe { onNext in
            let lineVC = XSLineViewController()
            self.navigationController?.pushViewController(lineVC, animated: true)
        }
        
        // 点击我的
        let _ = mineBtn.rx.tap.asObservable().subscribe { onNext in
            UMAnalyticsSwift.event(eventId: "1001")
            self.showMineVC()
        }
       
        // 点击会员
        let _ = memberBtn.rx.tap.asObservable().subscribe { onNext in
            self.navigationController?.pushViewController(XSMemberViewController(), animated: true)
        }
        
        // 点击滑动加速
        slideBtn.startClickBlick = { [self] in
            
            if currentUser == nil {
                oneKeyLogin.getPhoneNumber(currentVC: self)
                return true
            }
            
            if currentUser?.isVip != "1" {
                UMAnalyticsSwift.event(eventId: "1002")
                self.navigationController?.pushViewController(XSMemberViewController(), animated: true)
                return true
            }
                
            self.speedAction()
            UMAnalyticsSwift.event(eventId: "1006")
            return false
        }
        
        slideBtn.stopClickBlick = { [self] in
            self.manager.stopVPNConnection { err in
                
            }
            return false
        }
    }
    
    //MARK: 获取用户信息
    func getUserInfoData() {
        
        if currentUser == nil {
            return
        }
        self.showHub()
        requestManger.request(url: api.getUserInfo, params: ["phone": currentUser!.phone]) { success, result in
            self.hubHide()
            guard success else {
                self.showMessage(message: result.message)
                
                return
            }
            currentUser = XSUser(json: result.data)
            currentUser?.archived()
        }
    }
    
    @objc func updateStatus() {
        print("更新页面状态--\(self.manager.manager.connection.status)")
        switch self.manager.manager.connection.status {
        case .connected:
            print("开始")
            hubHide()
            slideBtn.changeToStatus(.start)
            break
        case .connecting:
            showHub()
            slideBtn.changeToStatus(.start)
            break
        case .disconnected:
            print("结束")
            hubHide()
            slideBtn.changeToStatus(.stop)
            break
        case .invalid:
            //为配置vpn
            checkStateAction()
            break
        default:
            print("ssssss")
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
        oneKeyLogin.register()
    }
    
    func updateUI() {
        guard selectModel != nil else {
            return
        }
        self.lineItem.lineTitleBtn.setTitle(selectModel?.name, for: .normal)
        self.lineItem.icon.kf.setImage(with: URL(string: selectModel?.icon ?? "") , placeholder: UIImage(named: "img_avatar_loading_def"))
        self.mapAnimation()
    }
    
    func checkStateAction() {
        manager.loadVPNPreference() { error in
            guard error == nil else {
//                fatalError("load VPN preference failed: \(error.debugDescription)")
                return
            }
            self.updateStatus()
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: NSNotification.Name.NEVPNStatusDidChange, object: self.manager.manager.connection)
        }
    }
    
    func speedAction() {
        manager.enableVPNManager() { error in
            guard error == nil else {
//                fatalError("enable VPN failed: \(error.debugDescription)")
                self.checkStateAction()
                return
            }
            self.manager.toggleVPNConnection() { error in
                guard error == nil else {
//                    fatalError("toggle VPN connection failed: \(error.debugDescription)")
                    return
                }
            }
        }
    }
    
    func closeMineVC() {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.allowAnimatedContent) {
            self.mineVC.view.frame = CGRect(x: -self.mineViewWidth, y: 0, width: self.mineViewWidth, height: UIScreen.main.bounds.height)
            self.maskView.backgroundColor = UIColor.init(white: 0, alpha: 0)
        } completion: { result in
            self.maskView.isHidden = true
        }
    }
    
    func showMineVC() {
        self.mineVC.updateUI()
        self.maskView.isHidden = false
        self.maskView.backgroundColor = .clear
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.allowAnimatedContent) {
            self.mineVC.view.frame = CGRect(x: 0, y: 0, width: self.mineViewWidth, height: UIScreen.main.bounds.height)
            self.maskView.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
        } completion: { result in
            
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }    
    
    func mapAnimation() {
        var height = UIScreen.main.bounds.height - 270
        if isSmallScreen {
            height += 50
        }
        if selectModel != nil {
            bgHeaderImageV.image = UIImage(named: selectModel!.continent.areaMap())
        } else {
            bgHeaderImageV.image = UIImage(named: Continent.none.areaMap())
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {[self] in
            bgHeaderImageV.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        } completion: { result in
            
        }
    }
    
    func prepareUI() {
        commonBackground()
        view.addSubview(bgHeaderImageV)
        view.addSubview(lineItem)
        view.addSubview(bgline)
        view.addSubview(downloadSpeed)
        view.addSubview(uploadSpeed)
        view.addSubview(testSpeedBtn)
        view.addSubview(slideBtn)
        view.addSubview(mineBtn)
        view.addSubview(memberBtn)
        
        let w = 300.0
        if isSmallScreen {
            bgHeaderImageV.frame = CGRect(x: (UIScreen.main.bounds.width - w)/2, y: 77, width: w, height: 196)
        } else {
            bgHeaderImageV.frame = CGRect(x: (UIScreen.main.bounds.width - w)/2, y: 47, width: w, height: 196)
        }

        lineItem.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 80))
            make.centerX.equalToSuperview().offset(10)
            if isSmallScreen {
                make.top.equalToSuperview().offset(132)
            } else {
                make.top.equalToSuperview().offset(152)
            }
        }
        bgline.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(34)
            make.right.equalTo(-34)
            if isSmallScreen {
                make.top.equalToSuperview().offset(241)
            } else {
                make.top.equalToSuperview().offset(281)
            }

        }
        
        if isSmallScreen {
            self.downloadSpeed.frame = CGRect(x: 50, y: 221+44, width: 100, height: 50)
            self.uploadSpeed.frame = CGRect(x: 50, y: 306+44, width: 100, height: 50)
            self.testSpeedBtn.frame = CGRect(x: UIScreen.main.bounds.width - 110 - 50, y: 281+44, width: 110, height: 40)
        } else {
            self.downloadSpeed.frame = CGRect(x: 50, y: 311+44, width: 100, height: 50)
            self.uploadSpeed.frame = CGRect(x: 50, y: 376+44, width: 100, height: 50)
            self.testSpeedBtn.frame = CGRect(x: UIScreen.main.bounds.width - 110 - 50, y: 351+44, width: 110, height: 40)
        }
        
        slideBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 98, height: 215))
            if isSmallScreen {
                make.bottom.equalTo(-40)
            } else {
                make.bottom.equalTo(-90)
            }
        }
        mineBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-110)
            make.size.equalTo(CGSize(width: 40, height: 52))
            if isSmallScreen {
                make.bottom.equalTo(-40)
            } else {
                make.bottom.equalTo(-60)
            }
        }
        memberBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(110)
            make.size.equalTo(CGSize(width: 40, height: 52))
            if isSmallScreen {
                make.bottom.equalTo(-40)
            } else {
                make.bottom.equalTo(-60)
            }
        }
    }

    func requestBanner() {
        requestManger.request(url: api.getBannerInfo) { success, result in
            self.hubHide()
            guard success else {
                self.showMessage(message: result.message)
                return
            }
            self.bannerList =  result.data.arrayValue.map({ object in
                XSBanner.init(json: object)
            })
        }
    }
    
    func requestLine() {
        showHub()
        requestManger.request(url: api.getLineList) { success, result in
            self.hubHide()
            guard success else {
                self.showMessage(message: result.message)
                return
            }
            let list =  result.data.arrayValue.map({ object in
                XSLineModel.init(json: object)
            })
            if selectModel == nil && result.data.count > 0 {
                selectModel = list.first
                selectModel?.archived()
                self.updateUI()
            }
        }
    }
    
    func showSpeedAlert() {
        let width = 345.0
        self.hubView.alpha = 0
        view.addSubview(self.hubView)
        view.addSubview(self.testSpeedView)
        self.testSpeedView.frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: UIScreen.main.bounds.height, width: width, height: width)
        self.testSpeedView.show(.scale, hubView: self.hubView)
    }
    
    func closeSpeedAlert() {
        self.testSpeedView.close(hubView: self.hubView)
        self.speedTestOK(upSpeed: 100, downSpeed: 120)
    }
    
    func speedTestOK(upSpeed:Int, downSpeed:Int) {
        self.uploadSpeed.speed.text = "0 Mbps"
        self.downloadSpeed.speed.text = "0 Mbps"

        var offset:CGFloat = 0
        if isSmallScreen {
            offset = -90.0
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .allowAnimatedContent) {
            self.downloadSpeed.frame = CGRect(x: 70, y: 341+16+offset, width: 100, height: 50)
            self.uploadSpeed.frame = CGRect(x: UIScreen.main.bounds.width - 70 - 100, y: 341+16+offset, width: 100, height: 50)
            self.testSpeedBtn.frame = CGRect(x: (UIScreen.main.bounds.width - 110)/2, y: 420+20+offset, width: 110, height: 40)
            self.uploadSpeed.speed.text = String(upSpeed) + " Mbps"
            self.downloadSpeed.speed.text = String(downSpeed) + " Mbps"

        } completion: { result in
            self.uploadSpeed.speed.text = String(arc4random() % 200 + 50) + "Mbps"
            self.downloadSpeed.speed.text = String(arc4random() % 80) + "Mbps"
        }
    }
    
    func speedTestNone() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .allowAnimatedContent) {
            self.downloadSpeed.frame = CGRect(x: 50, y: 331+44, width: 100, height: 50)
            self.uploadSpeed.frame = CGRect(x: 50, y: 396+44, width: 100, height: 50)
            self.testSpeedBtn.frame = CGRect(x: UIScreen.main.bounds.width - 110 - 50, y: 371+44, width: 110, height: 40)
        } completion: { result in
            self.uploadSpeed.speed.text = "-- Mbps"
            self.downloadSpeed.speed.text = "-- Mbps"
        }
    }
    
}
