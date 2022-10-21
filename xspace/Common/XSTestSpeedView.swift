//
//  XSTestView.swift
//  xspace
//
//  Created by Lendo on 2022/8/9.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit

let color666 = UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1)
let color999 =  UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1)

// MARK: -
class SpeedView:UIView {
    let arrow:UIImageView = {
        let imgv = UIImageView()
        return imgv
    }()
    
    let speedTip: UILabel = {
        let label = UILabel()
        label.text = "下载速度"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    let speed: UILabel = {
        let label = UILabel()
        label.text = "-- Mbps"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(arrow)
        self.addSubview(speed)
        self.addSubview(speedTip)
        arrow.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 18))
        }
        speedTip.snp.makeConstraints { make in
            make.left.equalTo(arrow.snp.right).offset(13)
            make.bottom.equalTo(arrow.snp_topMargin).offset(-2)
        }
        speed.snp.makeConstraints { make in
            make.left.equalTo(arrow.snp.right).offset(13)
            make.top.equalTo(arrow.snp_bottomMargin).offset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
}

// MARK: -
class PlanetView: UIView {
    static let width = 130
    static let smlWidth = 104
    let centerImagv:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "img_speed_earth")
        return imgv
    }()
    let firstCicle:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "img_line_sml2")
        return imgv
    }()
    let secondCicle:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "img_line_big2")
        return imgv
    }()
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(centerImagv)
        addSubview(firstCicle)
        addSubview(secondCicle)
        centerImagv.frame = CGRect(x: 0, y: 0, width: 73, height: 73)
        firstCicle.frame = CGRect(x: 0, y: 0, width: PlanetView.smlWidth, height: PlanetView.smlWidth)
        secondCicle.frame = CGRect(x: 0, y: 0, width: PlanetView.width, height: PlanetView.width)
        let c = CGPoint(x: PlanetView.width/2, y: PlanetView.width/2)
        firstCicle.center = c
        secondCicle.center = c
        centerImagv.center = c
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var angle: CGFloat = 150
    var a2 = 100.0
    @objc func rotationAngle() {
        UIView.animate(withDuration: 0.79, delay: 0, options: [ .beginFromCurrentState, .curveLinear]) {
            self.firstCicle.transform = CGAffineTransform(rotationAngle: self.a2 *  CGFloat(Double.pi / 180))
            self.secondCicle.transform = CGAffineTransform(rotationAngle: self.angle * CGFloat(Double.pi / 180))
        } completion: { result in
            self.angle = self.angle + 150
            self.a2 = self.a2 + 100
        }
    }
    
    func start() {
        if timer != nil {
            self.stop()
        } else {
            timer = Timer(timeInterval: 0.8, target: self, selector:#selector(rotationAngle), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
            timer?.fire()
        }
    }
    
    func stop() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}

// MARK: -
class XSTwoLabels: UIView {
    enum Style: Int {
     case yanshi = 10, doudong, diubao
        func title()->String {
            switch self {
            case .yanshi:
                return "延时/ms"
            case .doudong:
                return "抖动/ms"
            case .diubao:
                return "丢包/%"
            }
        }
    }
    
    let tipTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1)

        return label
    }()
    
    let content: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1)
        label.text = "0"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tipTitle)
        addSubview(content)
        tipTitle.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        content.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipTitle.snp.bottom).offset(20)
            
        }
    }
    
    convenience init(style:Style) {
        self.init(frame: CGRect.zero)
        self.tipTitle.text = style.title()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: -
class XSTestSpeedView: UIView {
    let downloadSpeed: SpeedView = {
        let view = SpeedView()
        view.speedTip.text = "下载速度"
        view.speedTip.textColor = color999
        view.speed.textColor = color666
        view.speed.text = "-- Mbps"
        view.arrow.image = UIImage.init(named: "img_home_arrow_greed")
        return view
    }()
    
    let uploadSpeed: SpeedView = {
        let view = SpeedView()
        view.speedTip.text = "上传速度"
        view.speedTip.textColor = color999
        view.speed.textColor = color666
        view.arrow.image = UIImage.init(named: "img_home_arrow_red")
        view.speed.text = "-- Mbps"
        return view
    }()
    
    let cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btn_speed_closure"), for: .normal)
        return btn
    }()
    
    let yanshi: XSTwoLabels = {
        let label = XSTwoLabels(style: .yanshi)
        return label
    }()
    
    let doudong: XSTwoLabels = {
        let label = XSTwoLabels(style: .doudong)
        return label
    }()
    
    let diubao: XSTwoLabels = {
        let label = XSTwoLabels(style: .diubao)
        return label
    }()
    
    let xingqiu = PlanetView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 16
        
        addSubview(downloadSpeed)
        addSubview(uploadSpeed)
        addSubview(yanshi)
        addSubview(doudong)
        addSubview(diubao)
        addSubview(cancelBtn)
        addSubview(xingqiu)
        
        downloadSpeed.snp.makeConstraints { make in
            make.top.equalTo(65)
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerX.equalToSuperview().offset(-90)
        }
        uploadSpeed.snp.makeConstraints { make in
            make.top.equalTo(downloadSpeed.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerX.equalToSuperview().offset(-90)
        }
        xingqiu.snp.makeConstraints { make in
            make.top.equalTo(65)
            make.width.height.equalTo(PlanetView.width)
            make.centerX.equalToSuperview().offset(80)
        }
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.right.equalTo(-20)
            make.width.height.equalTo(20)
        }
        doudong.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(62)
            make.width.equalTo(90)
            make.bottom.equalTo(-44)
        }
        yanshi.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-90)
            make.height.equalTo(62)
            make.width.equalTo(90)
            make.bottom.equalTo(-44)

        }
        diubao.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(90)
            make.bottom.equalTo(-44)
            make.height.equalTo(62)
            make.width.equalTo(90)
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum AppearStyle {
        case scale, rise, none
    }
    
    private var appearStyle:AppearStyle = .none
    func show(_ appear:AppearStyle ,hubView:UIView) {
        appearStyle = appear
        self.downloadSpeed.speed.text = "-- Mbps"
        self.uploadSpeed.speed.text = "-- Mbps"
        self.doudong.content.text = "0"
        self.yanshi.content.text = "0"
        self.diubao.content.text = "0"
        
        let width = self.bounds.width
        let targetR = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: (UIScreen.main.bounds.height - width) / 2, width: width, height: width)
        if appear == .none {
            hubView.alpha = 1
            self.frame = targetR
            self.xingqiu.start()
        } else if appear == .rise {
            UIView.animate(withDuration: 0.25, delay: 0, options: .allowAnimatedContent) {
                hubView.alpha = 1
                self.frame = targetR
            } completion: { result in
                self.xingqiu.start()
            }
        } else if appear == .scale {
            self.alpha = 0
            self.frame = targetR
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .allowAnimatedContent) {
                hubView.alpha = 1
                self.alpha = 1
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { result in
                self.xingqiu.start()
            }
        }
        
        if !GCDTimer.share.isExistTimer(withName: "uploadTime") {
            GCDTimer.share.scheduledDispatchTimer(withName: "uploadTime", timeInterval: 0.8, queue: .main, repeats: true) {
                self.uploadSpeed.speed.text = String(arc4random() % 200 + 50) + "Mbps"
             }
        }
        
        if !GCDTimer.share.isExistTimer(withName: "downloadTime") {
            GCDTimer.share.scheduledDispatchTimer(withName: "downloadTime", timeInterval: 1.2, queue: .main, repeats: true) {
                self.downloadSpeed.speed.text = String(arc4random() % 80) + "Mbps"
             }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.yanshi.content.text = String(arc4random() % 20 + 3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.doudong.content.text = String(arc4random() % 5 + 1) + "." + String(arc4random() % 100 + 10)
        }
    }
    
    func close(hubView:UIView) {
        let width = self.bounds.width
        let targetR = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: UIScreen.main.bounds.height, width: width, height: width)
        if appearStyle == .none {
            hubView.alpha = 0
            self.frame = targetR
            self.xingqiu.stop()
            hubView.removeFromSuperview()
            self.removeFromSuperview()
        } else if appearStyle == .rise {
            UIView.animate(withDuration: 0.25, delay: 0, options: .allowAnimatedContent) {
                hubView.alpha = 0
                self.frame = targetR
            } completion: { result in
                self.xingqiu.stop()
                hubView.removeFromSuperview()
                self.removeFromSuperview()
            }
        } else if appearStyle == .scale {
            UIView.animate(withDuration: 0.25, delay: 0, options: .allowAnimatedContent) {
                hubView.alpha = 0
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { result in
                self.xingqiu.stop()
                self.frame = targetR
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                hubView.removeFromSuperview()
                self.removeFromSuperview()
            }
        }
        
        if GCDTimer.share.isExistTimer(withName: "uploadTime") {
            GCDTimer.share.destoryTimer(withName: "uploadTime")
        }
        
        if GCDTimer.share.isExistTimer(withName: "downloadTime") {
            GCDTimer.share.destoryTimer(withName: "downloadTime")
        }
    }
}
