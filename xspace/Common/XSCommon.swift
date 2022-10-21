//
//  XSCommon.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
import RxSwift
import RxCocoa

let colorGreen = UIColor(red: 0.31, green: 0.77, blue: 0.24, alpha: 1)
let colorRed = UIColor(red: 0.95, green: 0.29, blue: 0.29, alpha: 1)
let colorCCC = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
let colorOrange = UIColor(red: 1, green: 0.44, blue: 0.2, alpha: 1)
let colorYellew = UIColor(red: 1, green: 0.68, blue: 0.13, alpha: 1)
let colorYellew2 = UIColor(red: 1, green: 0.36, blue: 0.13, alpha: 1)

// 状态栏高度
let StatusBarHeight = (IsNeatBang ? 44 : 20)



//判断是否是齐刘海
var IsNeatBang: Bool {
    if isPad() {
//        return false
        if #available(iOS 11, *) {
              guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                  return false
              }
              
              if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                  
                  return true
              }
        }
        return false
    }else {
        if #available(iOS 11, *) {
              guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                  return false
              }
              
              if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                  
                  return true
              }
        }
        return false
    }
}
//判断是否是ipad
func isPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}
// 通知
let kHadLoginNoticeName = "kLoginSuccess"

var isSmallScreen:Bool {
    return UIScreen.main.bounds.height <= 667
}
func kRealScale(_ num: CGFloat) -> CGFloat{
    if isSmallScreen {
        return UIScreen.main.bounds.height / 812 * num
    } else {
        return num
    }
}

/**比例换算**/

func SXRealValue( _ font : CGFloat) -> CGFloat {
    return font * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / (375)
}

func timeStampToDateString(time:String) -> String {
    if let t = Double(time) {
        let date = NSDate(timeIntervalSince1970: t/1000)
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd"
        return dfmatter.string(from: date as Date)
    }
    return ""
}

extension Date {
    var milliStamp :String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisec = CLongLong(round(timeInterval * 1000))
        return "\(millisec)"
    }
}

// MARK: -
extension UIViewController {
    func showMessage(message:String) {
        self.hubHide()
        self.view.makeToast(message, duration: 2.0, position: .center)
    }
    
    func showHub() {
        self.view.makeToastActivity(.center)
    }
    
    func hubHide() {
        self.view.hideToastActivity()
    }
    
}

extension UIViewController: UIGestureRecognizerDelegate {
    func commonBackground() {
        let layerView = UIView()
        layerView.frame = UIScreen.main.bounds
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(red: 0.05, green: 0.13, blue: 0.25, alpha: 1).cgColor, UIColor(red: 0.16, green: 0.26, blue: 0.4, alpha: 1).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = layerView.bounds
        bgLayer1.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
        layerView.layer.addSublayer(bgLayer1)
        view.addSubview(layerView)
    }
    
    func whiteNavBar() {
        self.navigationController?.isNavigationBarHidden = true
        let btn = UIButton(frame: CGRect(x: 0, y: StatusBarHeight, width: 44, height: 44))
        btn.addTarget(self, action:  #selector(back), for: .touchUpInside)
        btn.setImage(UIImage(named: "btn_log_arrow"), for: .normal)
        self.view.addSubview(btn)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
        
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: -
class TopImageBtn: UIButton {
    let icon:UIImageView = {
        let imgv = UIImageView()
        return imgv
    }()
  
    let bottomTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(icon)
        self.addSubview(bottomTitle)
        bottomTitle.textColor = .white
        icon.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        bottomTitle.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(7)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class rightImageBtn: UIButton {
    let icon:UIImageView = {
        let imgv = UIImageView()
        return imgv
    }()
  
    let bottomTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(icon)
        self.addSubview(bottomTitle)
        bottomTitle.textColor = .white
        bottomTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        
        icon.snp.makeConstraints { make in
            make.left.equalTo(bottomTitle.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 11, height: 12))
        }
        
        self.imageView?.isHidden = true
        self.titleLabel?.isHidden = true
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        self.bottomTitle.text = title
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        self.icon.image = image
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


//颜色
/// 通过 十六进制与alpha来设置颜色值  （ 样式： 0xff00ff ）
public let HexRGBAlpha:((Int,Float) -> UIColor) = { (rgbValue : Int, alpha : Float) -> UIColor in
    return UIColor(red: CGFloat(CGFloat((rgbValue & 0xFF0000) >> 16)/255), green: CGFloat(CGFloat((rgbValue & 0xFF00) >> 8)/255), blue: CGFloat(CGFloat(rgbValue & 0xFF)/255), alpha: CGFloat(alpha))
}
