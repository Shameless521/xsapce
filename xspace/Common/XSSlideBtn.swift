//
//  XSSlideBtn.swift
//  xspace
//
//  Created by Lendo on 2022/8/17.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import MapKit

typealias ClickBlock = ()->(Bool)

// MARK: - 滑动按钮
class XSSlideBtn: UIView {
    let bg:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "btn_bg_switch")
        return imgv
    }()
    
    let subItemH: CGFloat = 108
    let subItem:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "btn_switch_child")
        imgv.isUserInteractionEnabled = true
        return imgv
    }()
    
    let speedTip: UILabel = {
        let label = UILabel(frame: CGRect(x: 19, y: 66, width: 48, height: 18))
        label.text = "滑动加速"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .white
        return label
    }()
    
    let statusCircle: UIView = {
        let view = UIView(frame: CGRect(x: 29, y: 29, width: 28, height: 28))
        view.layer.cornerRadius = 14;
        view.layer.borderColor = colorGreen.cgColor
        view.layer.borderWidth = 2
//        view.isHidden = true
        return view
    }()
        
    let topDirection:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "btn_home_slide_up")
        return imgv
    }()
    
    let downDirection:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "btn_home_slide_down")
        return imgv
    }()
    
    let content:UIView = UIView()
    
    let upShimmerView : MKShimmerView = {
        let view = MKShimmerView(frame: CGRect.zero)
        view.shimmering = true
        view.shimmeringDirection = .up
        view.shimmeringBeginFadeDuration = 0
        view.shimmeringSpeed = 100
        view.shimmeringBeginTime = CACurrentMediaTime()
        view.shimmeringFadeTime =  CACurrentMediaTime() + 4
        view.shimmeringOpacity = 0.3
        view.shimmeringAnimationOpacity = 1
        view.shimmeringPauseDuration = 1.5
        view.shimmeringEndFadeDuration = 0
        return view
    }()
    
    let downShimmerView : MKShimmerView = {
        let view = MKShimmerView(frame: CGRect.zero)
        view.shimmering = true
        view.shimmeringDirection = .down
        view.shimmeringBeginFadeDuration = 0
        view.shimmeringSpeed = 100
        view.shimmeringBeginTime = CACurrentMediaTime()
        view.shimmeringFadeTime =  CACurrentMediaTime() + 4
        view.shimmeringOpacity = 0.3
        view.shimmeringAnimationOpacity = 1
        view.shimmeringPauseDuration = 1.5
        view.shimmeringEndFadeDuration = 0
        return view
    }()
    
    var startClickBlick: ClickBlock?
    var stopClickBlick: ClickBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bg)
        self.addSubview(content)

        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        content.frame = CGRect(x:6, y: 7, width: frame.width - 12, height: frame.height - 14)
        
        content.addSubview(upShimmerView)
        content.addSubview(downShimmerView)
        upShimmerView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 17, height: 31))
            make.top.equalTo(40)
            make.centerX.equalToSuperview()
        }
        downShimmerView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 17, height: 31))
            make.bottom.equalTo(-40)
            make.centerX.equalToSuperview()
        }
        upShimmerView.contentView = topDirection
        downShimmerView.contentView = downDirection
//        content.addSubview(topDirection)
//        content.addSubview(downDirection)
        content.addSubview(subItem)
        subItem.frame = CGRect(x: 0, y: content.bounds.height - subItemH, width: content.bounds.width, height: subItemH)
        topDirection.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 17, height: 31))
            make.top.equalTo(40)
            make.centerX.equalToSuperview()
        }
        downDirection.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 17, height: 31))
            make.bottom.equalTo(-40)
            make.centerX.equalToSuperview()
        }
        downDirection.alpha = 0
        subItem.addSubview(statusCircle)
        subItem.addSubview(speedTip)
        self.subItem.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(speed))
//        self.subItem.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    enum StartupStatus:Int {
        case stop , start
    }
    
    var status:StartupStatus = .stop
//    @objc func speed() {
//        let w = self.content.bounds.width
//        if status == .stop {
//            self.downDirection.alpha = 0
//            self.topDirection.alpha = 1
//            self.subItem.frame = CGRect(x: 0, y: self.content.frame.height - 108, width: w, height: 108)
//            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.allowAnimatedContent) {
//                self.downDirection.alpha = 1
//                self.topDirection.alpha = 0
//                self.subItem.frame = CGRect(x: 0, y: 0, width:w, height: 108)
//            } completion: { success in
//                self.status = .start
//                self.statusCircle.layer.borderColor = colorRed.cgColor
//                self.speedTip.text = "停止加速"
//                if let _ = self.startClickBlick {
//                    self.startClickBlick!()
//                }
//            }
//        } else {
//            self.downDirection.alpha = 1
//            self.topDirection.alpha = 0
//            self.subItem.frame = CGRect(x: 0, y: 0, width: w, height: 108)
//            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.allowAnimatedContent) {
//                self.downDirection.alpha = 0
//                self.topDirection.alpha = 1
//                self.subItem.frame = CGRect(x: 0, y: self.content.frame.height - 108, width: w, height: 108)
//            } completion: { success in
//                self.status = .stop
//                self.speedTip.text = "滑动加速"
//                self.statusCircle.layer.borderColor = colorGreen.cgColor
//                if let _ = self.stopClickBlick {
//                    self.stopClickBlick!()
//                }
//            }
//        }
//    }
    
    // MARK: - 拖动模块
    private var isTouchSubItem:Bool = false
    private var percentY = 1.0 //高度位置
    private var previousPointY = 0.0
    private var touchPointY = 0.0  //InLocalView
    var adsorb: Bool = false  //滑动后始终处于初始位置

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.subItem || touch?.view == self.statusCircle {
            isTouchSubItem = true
            var point = touch?.location(in: self.content) ?? CGPoint.zero
            previousPointY = point.y
            point = touch?.location(in: self.subItem) ?? CGPoint.zero
            touchPointY = point.y
        } else {
            isTouchSubItem = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouchSubItem else {
            return
        }
        let touch = touches.first
        let point = touch?.location(in: self) ?? CGPoint.zero
        var y = point.y-touchPointY
        
        if y > self.content.frame.height - subItemH {
            y = self.content.frame.height - subItemH
        }
        if y < 0 {
            y = 0
        }
        percentY = y / (self.content.bounds.height - subItemH)
        subItem.frame = CGRect(x: 0, y: y, width: content.bounds.width, height: subItemH)
        self.downDirection.alpha = 1 - percentY
        self.topDirection.alpha =  percentY
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouchSubItem else {
            return
        }
        isTouchSubItem = false
        var y = 0.0

        // adsorb == true , 按钮回到原来位置
        if percentY >= 0.5 {
            y = self.content.frame.height - subItemH
            if let _ = self.stopClickBlick {
                adsorb = self.stopClickBlick!()
            }

        } else {
            y = 0
            if let _ = self.startClickBlick {
                adsorb = self.startClickBlick!()
            }
        }

        if adsorb {
            adsorbAnimation(status: self.status)
            return
        }
        self.subItem.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2 * percentY, delay: 0, options: UIView.AnimationOptions.curveEaseOut) {
            self.subItem.frame = CGRect(x: 0, y: y, width: self.content.bounds.width, height: self.subItemH)
            if y == 0 {
                self.downDirection.alpha = 1
                self.topDirection.alpha = 0
                self.status = .start
                self.statusCircle.layer.borderColor = colorRed.cgColor
                self.speedTip.text = "停止加速"

            } else {
                self.downDirection.alpha = 0
                self.topDirection.alpha = 1
                self.status = .stop
                self.speedTip.text = "滑动加速"
                self.statusCircle.layer.borderColor = colorGreen.cgColor
            }
        } completion: { result in
            self.subItem.isUserInteractionEnabled = true
            self.previousPointY = y
        }
    }
    
    /// 吸附效果，滑动一半的时候，自动黏贴到上下边
    /// StartupStatus 控制上下边
    func adsorbAnimation(status: StartupStatus, _ dur: CGFloat = 0.1) {
        var y: CGFloat = 0
        if (status == .stop) {
            y = self.content.frame.height - subItemH
            self.status = .stop
            self.speedTip.text = "滑动加速"
            self.statusCircle.layer.borderColor = colorGreen.cgColor
        } else {
            y = 0
            self.status = .start
            self.statusCircle.layer.borderColor = colorRed.cgColor
            self.speedTip.text = "停止加速"
        }

        UIView.animate(withDuration: dur, delay: 0, options: UIView.AnimationOptions.curveLinear) {
            self.subItem.frame = CGRect(x: 0, y: y, width: self.content.bounds.width, height: self.subItemH)
            if y == 0 {
                self.downDirection.alpha = 1
                self.topDirection.alpha = 0
            } else {
                self.downDirection.alpha = 0
                self.topDirection.alpha = 1
            }
        } completion: { result in
            self.subItem.isUserInteractionEnabled = true
            self.previousPointY = y
        }
    }
    
    func changeToStatus(_ s: StartupStatus) {
        status = s
        adsorbAnimation(status: s , 0.2)
    }
}

