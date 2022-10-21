//
//  XSMineViewController.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
class Avatars: UIView {
    let icon:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage(named: "btn_mine_avatar")
        return imgv
    }()
    
    var name: UILabel = {
        let label = UILabel()
        label.text = "登录/注册"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    var vipTip :UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.titleLabel?.textColor = .white
        btn.setTitle("超级会员", for: .normal)
        btn.layer.cornerRadius = 9
        btn.clipsToBounds = true
        btn.setBackgroundImage(UIImage(named: "btn_bg"), for: .normal)
        return btn
    }()
    
    let tap = UITapGestureRecognizer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(icon)
        self.addSubview(name)
        self.addSubview(vipTip)
        icon.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        name.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(13)
            make.centerY.equalToSuperview()
        }
        vipTip.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 56, height: 18))
            make.left.equalTo(icon.snp.right).offset(13)
            make.top.equalTo(name.snp.bottom).offset(4)
        }
        vipTip.isHidden = true
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(self.tap)
    }
    
    func showVip() {
        name.snp.remakeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(13)
            make.top.equalToSuperview().offset(3)
        }
        vipTip.isHidden = false
    }
    
    func hiddenVip() {
        name.snp.remakeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(13)
            make.centerY.equalToSuperview()
        }
        vipTip.isHidden = true
    }
    
    func unLoginStyle() {
        hiddenVip()
        name.text = "登录/注册"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

class XSMineViewController: UIViewController {
    
//    var list:Array<String> = ["海外模式","关于我们"]
    var list:Array<String> = ["关于我们"]
    var selectModel: XSLineModel? = nil
    let loginOutBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("退出账号", for: .normal)
        return btn
    }()
    
    let tableView: UITableView = {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.height), style: .plain)
        table.register(XSMineTableViewCell.self, forCellReuseIdentifier: "XSMineTableViewCell")
        table.backgroundColor = HexRGBAlpha(0x405575,1)
        table.separatorStyle = .none
        return table
    }()
    
    let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kRealScale(200)))
    
    var avatars:Avatars = {
        let a = Avatars()
        return a
    }()
    
    let becomeMember: UIButton = {
        let btn = UIButton()
        btn.setTitle("升级会员", for: .normal)
        btn.setBackgroundImage(UIImage(named: "btn_bg"), for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 19
        btn.clipsToBounds = true
        return btn
    }()

    var expireLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.text = "到期时间:"
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        let _ = avatars.tap.rx.event.asObservable().subscribe { onNext in
            if currentUser == nil {
                let nav = self.view.window?.rootViewController as? UINavigationController
                oneKeyLogin.getPhoneNumber(currentVC: (nav?.topViewController)!)
            }
        }
        
        let _ = becomeMember.rx.tap.asObservable().subscribe { next in
            let nav = self.view.window?.rootViewController as? UINavigationController
            nav?.pushViewController(XSMemberViewController(), animated: true)
        }
        
        let _ = loginOutBtn.rx.tap.asObservable().subscribe {[self] next in
            self.loginOutAction()
        }
        
       let _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: kHadLoginNoticeName)).take(until:self.rx.deallocated).subscribe { next in
            self.updateUI()
        }
    }

    func loginOutAction() {
        let nav = self.view.window?.rootViewController as? UINavigationController
        nav?.topViewController!.showHub()
        requestManger.request(url: api.loginOut, params: ["phone":currentUser!.phone]) { success, result in
            if success {
                currentUser = nil
                XSUser.clearUserArchive()
                self.updateUI()
                nav?.topViewController!.hubHide()
            } else {
                nav?.topViewController!.showMessage(message: result.message)
            }
        }
    }

    
    func updateUI() {
        func userCanShowVip(isVip:Bool) {
            if isVip {
                avatars.showVip()
                becomeMember.isHidden = true
                expireLabel.isHidden = false
                expireLabel.text = "到期时间: " + timeStampToDateString(time: currentUser!.exprieTime)
            } else {
                avatars.hiddenVip()
                becomeMember.isHidden = false
                expireLabel.isHidden = true
            }
        }
        
        if currentUser != nil {
            headerView.frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kRealScale(270))
            avatars.name.text = currentUser!.userName
            loginOutBtn.isHidden = false
            if currentUser?.isVip == "1" {
                userCanShowVip(isVip: true)
            } else {
                userCanShowVip(isVip: false)
            }
//            self.list = ["海外模式","关于我们","注销用户"]
            self.list = ["关于我们","注销用户"]
        
        } else {
            headerView.frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: kRealScale(200))
            becomeMember.isHidden = true
            loginOutBtn.isHidden = true
            expireLabel.isHidden = true
            avatars.unLoginStyle()
//            self.list = ["海外模式","关于我们"]
            self.list = ["关于我们"]
        }
        let vv = headerView.viewWithTag(1000)
        vv?.isHidden = becomeMember.isHidden
        self.tableView.reloadData()
        
    }
    
    func prepareUI() {
        whiteNavBar()
        commonBackground()
        view.clipsToBounds = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerView.addSubview(avatars)
        avatars.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.size.equalTo(CGSize(width: kRealScale(200), height: kRealScale(55)))
            make.top.equalTo(kRealScale(90))
        }
        
        headerView.addSubview(becomeMember)
        becomeMember.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: kRealScale(195), height: 38))
            make.top.equalTo(avatars.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        headerView.addSubview(expireLabel)
        expireLabel.snp.makeConstraints { make in
            make.top.equalTo(avatars.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(loginOutBtn)
        loginOutBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 70 , height: 38))
            if isSmallScreen {
                make.bottom.equalToSuperview().offset(-40)
            } else {
                make.bottom.equalToSuperview().offset(-80)
            }
            make.centerX.equalToSuperview()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension XSMineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:XSMineTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "XSMineTableViewCell", for: indexPath) as! XSMineTableViewCell
        cell.contentTitle.text = list[indexPath.row]
        cell.switchBtn.isHidden = true
        cell.rightIcon.isHidden = false
//        if indexPath.row == 0 {
//            cell.switchBtn.isHidden = false
//            cell.rightIcon.isHidden = true
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nav = self.view.window?.rootViewController as? UINavigationController

        switch indexPath.row {

        case 0:
            let web = XSWebViewController()
            web.url = kAboutURL
            nav?.pushViewController(web, animated: true)
            if currentUser != nil {
                self.list = ["关于我们","注销用户"]
            }else {
                self.list = ["关于我们"]
            }
            self.tableView.reloadData()
            break
        case 1:
            let params = ["phone":currentUser!.phone as Any] as [String : Any]
            self.showHub()
            requestManger.request(url: api.cancelUser , params: params) { [self] success, result in
                hubHide()
                guard success else {
                    self.showMessage(message: result.message)
                    return
                }
                showMessage(message: "注销成功")
                let nav = self.view.window?.rootViewController as? UINavigationController
                nav?.topViewController!.showHub()
                currentUser = nil
                XSUser.clearUserArchive()
                self.updateUI()
                nav?.topViewController!.hubHide()
            }
            break

        default:
            return
        }
    }
}
