//
//  XSLoginViewController.swift
//  xspace
//
//  Created by Lendo on 2022/8/3.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CryptoSwift
import SwiftUI
import Alamofire

class CodeView: UIView {
    var timer:DispatchSourceTimer?
    var count:Int = 60
    let bg = UIView()
    var clickBlock:()->() = {}
    let realBtn: UIButton = {
        let btn = UIButton()
        return btn
    }()
    let title: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: 25, height: 22))
        label.text = "获取验证码"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bg)
        addSubview(title)
        addSubview(realBtn)
        self.isUserInteractionEnabled = true
        layer.cornerRadius = frame.height / 2
        bg.frame = bounds
        title.frame = bounds
        clipsToBounds = true
        backgroundColor = .gray
        realBtn.addTarget(self, action: #selector(click), for: .touchUpInside)
        realBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    static func defaultCodeBtn() -> CodeView {
        let code = CodeView(frame: CGRect(x: 0, y: 0, width: 98, height: 32))
        code.bg.layer.contents = UIImage(named: "btn_bg")?.cgImage
        return code
    }
    
    func isCount() -> Bool {
        if self.title.text?.count == "获取验证码".count {
            return false
        }
        return true
    }
    
    @objc func click() {
        guard !self.isCount() else {
            return
        }
        clickBlock()
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: DispatchTime.now(), repeating: .seconds(1))
        timer?.setEventHandler(handler: {
            if self.count > 0 {
                self.count-=1
                DispatchQueue.main.async {
                    self.title.text = String(self.count) + "s"
                    self.bg.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self.timer?.cancel()
                    self.title.text = "获取验证码"
                    self.bg.isHidden = false
                }
            }
        })
        timer?.resume()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

class XSTextField: UITextField {
        
    func setLightStyle()  {
        let btn = self.value(forKey: "_clearButton") as? UIButton
        btn?.setImage(UIImage(named: "btn_log_closure"), for: .normal)
    }
}
class PhoneItemView: UIView {
    enum Style {
        case code, phone
    }
    
    let tip: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 12, width: 28, height: 22))
        label.text = "+86"
        label.font = UIFont.systemFont(ofSize: SXRealValue(15), weight: .regular)
        label.textColor = .white
        return label
    }()
    
    let textFeild: XSTextField = {
        let t = XSTextField(frame: CGRect(x: 56, y: 12, width: 100, height: 22))
        t.placeholder = "请输入手机号"
//        t.text = "17648282333"
        t.attributedPlaceholder = NSAttributedString(string: t.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : HexRGBAlpha(0xD9D9D9, 0.8) , NSAttributedString.Key.font: UIFont.systemFont(ofSize: SXRealValue(15))])
//        t.attributedPlaceholder = NSAttributedString(string: t.placeholder!, attributes: [])
    
        t.font = UIFont.systemFont(ofSize: SXRealValue(15))
        t.textColor = UIColor.white
        t.clearButtonMode = .whileEditing
        t.keyboardType = UIKeyboardType.phonePad
        t.setLightStyle()
        return t
    }()
    
    let code = CodeView.defaultCodeBtn()
    let lineL = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addLine()
        self.addSubview(tip)
        self.addSubview(textFeild)
        textFeild.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview()
            make.height.equalTo(22)
        }
        tip.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
     
    }
    
    func addLine() {
        lineL.backgroundColor = HexRGBAlpha(0xffffff, 0.15)
        self.addSubview(lineL)
        lineL.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    convenience init(frame: CGRect, style:Style) {
        self.init(frame: frame)
        if style == .code{
            addSubview(code)
            code.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview().offset(3)
                make.size.equalTo(CGSize(width: 98, height: 32))
            }
            lineL.snp.remakeConstraints { make in
                make.right.equalTo(code.snp.left).offset(-5)
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.height.equalTo(1)
            }
            textFeild.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(56)
                make.right.equalTo(code.snp.left).offset(-8)
                make.height.equalTo(22)
            }
//            textFeild.text = "789987"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class XSLoginViewController: UIViewController {
    let bgHeaderImageV:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage.init(named: "bg_login")
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
    let icon:UIImageView = {
        let imgv = UIImageView.init(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 53, y: kRealScale(105 + 44), width: kRealScale(106), height: kRealScale(106)))
        imgv.layer.cornerRadius = 25
        imgv.image = UIImage(named: "login_logo")
        return imgv
    }()
    
    let privacyBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btn_login_sel"), for: .selected)
        btn.setImage(UIImage(named: "btn_login"), for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: SXRealValue(12))
        return btn
    }()
    
    var privacyLabel :RichTextLabel = {
        let label = RichTextLabel()
        label.font = UIFont.systemFont(ofSize: SXRealValue(12))
        label.textColor = .white
        label.setSting("登录即同意《服务条款》和《隐私协议》，并授权星舰加速器获取手机号")
        label.numberOfLines = 2
        return label
    }()

    let phoneView = PhoneItemView()
    let codeView: PhoneItemView = {
        let v = PhoneItemView(frame: CGRect.zero, style: .code)
        v.tip.isHidden = true
        v.code.isHidden = false
        v.textFeild.placeholder = "请输入验证码"
        v.textFeild.attributedPlaceholder = NSAttributedString(string: v.textFeild.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : HexRGBAlpha(0xD9D9D9, 0.8) , NSAttributedString.Key.font: UIFont.systemFont(ofSize: SXRealValue(15))])

        return v
    }()
    
    let loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("登录", for: .normal)
        btn.setBackgroundImage(UIImage(named: "btn_bg"), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: SXRealValue(16))
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonBackground()
        prepareUI()
        whiteNavBar()
        let _ = loginBtn.rx.tap.asObservable().subscribe { [self] onNext in
            loginAction()
        }
        codeView.code.clickBlock = { [self] in
            sendCode()
        }
    }
    
    func sendCode() {
        guard let _ = self.phoneView.textFeild.text else {
            self.showMessage(message: "请输入手机号")
            return
        }
        let params = ["userPhone":self.phoneView.textFeild.text!, "udid":IDFA ,"driveType": 0] as [String : Any]
        self.showHub()
        requestManger.request(url: api.sendCode , params: params) { [self] success, result in
            hubHide()
            guard success else {
                self.showMessage(message: result.message)
                return
            }
            showMessage(message: "已发送")
        }
    }
    
    func loginAction() {
        // MARK: - 需要删除
//        currentUser = XSUser.init(dic:nil)
//        currentUser?.archived()
//        showMessage(message: "登录成功")
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHadLoginNoticeName), object: nil, userInfo: nil)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.navigationController?.popToRootViewController(animated: true)
//        }
//        return
        
        if self.phoneView.textFeild.text?.count == 0 {
            self.showMessage(message: "请输入手机号")
            return
        }
        guard let _ = self.codeView.textFeild.text else {
            self.showMessage(message: "请输入验证码")
            return
        }
        guard self.privacyBtn.isSelected else {
            self.showMessage(message: "请同意《隐私政策》和《服务协议》")
            return
        }
        let params = ["userPhone":self.phoneView.textFeild.text!, "udid":IDFA ,"driveType": 0, "userCode": self.codeView.textFeild.text!] as [String : Any]
        self.showHub()
        requestManger.request(url: api.checkCode , params: params) { [self] success, result in
            hubHide()
            guard success else {
                showMessage(message: result.message)
                return
            }
            currentUser = XSUser(json: result.data)
            currentUser?.archived()
            showMessage(message: "登录成功")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHadLoginNoticeName), object: nil, userInfo: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    func prepareUI() {
        view.addSubview(bgHeaderImageV)
        view.addSubview(icon)
        view.addSubview(phoneView)
        view.addSubview(codeView)
        view.addSubview(loginBtn)
        view.addSubview(privacyBtn)
        view.addSubview(privacyLabel)
        
        bgHeaderImageV.frame = UIScreen.main.bounds

        phoneView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kRealScale(300))
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(40)
        }
        codeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kRealScale(360))
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(40)
        }
        loginBtn.snp.makeConstraints { make in
            make.top.equalTo(codeView.snp.bottom).offset(kRealScale(50))
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(44)
        }
        privacyBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-44)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        privacyLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-kRealScale(44))
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(40)
        }
        
        let _ =  privacyBtn.rx.tap.asObservable().subscribe { [self] onNext in
            self.privacyBtn.isSelected = !self.privacyBtn.isSelected
        }

        privacyLabel.addClickBlock({ [self] in
            let webView = XSWebViewController()
            webView.url = kPrivacyURL
            self.navigationController?.pushViewController(webView, animated: true)
        }, string: "《隐私协议》", color: colorYellew2)

        privacyLabel.addClickBlock({
            let webView = XSWebViewController()
            webView.url = kServiceURL
            self.navigationController?.pushViewController(webView, animated: true)
        }, string: "《服务条款》", color: colorYellew2)
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}
