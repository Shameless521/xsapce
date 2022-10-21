//
//  XSLineViewController.swift
//  xspace
//
//  Created by Lendo on 2022/8/8.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import SwiftyJSON

class XSLineViewController: UIViewController {

    var list:Array<XSLineModel> = []
    
    let bgHeaderImageV:UIImageView = {
        let imgv = UIImageView()
        imgv.image = UIImage.init(named: "img_home_map")
        imgv.contentMode = .scaleAspectFill

        return imgv
    }()
    
    let tableView: UITableView = {
        let top = 250.0
        let table = UITableView(frame: CGRect(x: 0, y: top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - top), style: .plain)
        table.register(XSLineTableViewCell.self, forCellReuseIdentifier: "XSLineTableViewCell")
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        return table
    }()
    
    let lineItem: LineItem = {
        let item = LineItem()
        item.lineTitleBtn.setImage(nil, for: .normal)
        return item
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        tableView.delegate = self
        tableView.dataSource = self
        request()
        updateLineItemView()
    }
    
    func updateLineItemView() {
        self.lineItem.lineTitleBtn.setTitle(selectModel?.name, for: .normal)
        self.lineItem.icon.kf.setImage(with: URL(string: selectModel?.icon ?? "") , placeholder: UIImage(named: "img_avatar_loading_def"))
        
        UIView.animate(withDuration: 0.35, delay: 0, options: UIView.AnimationOptions.curveEaseIn) {[self] in
            guard selectModel != nil else {
                bgHeaderImageV.image = UIImage(named: Continent.none.areaMap())
                return ;
            }
            bgHeaderImageV.image = UIImage(named: selectModel!.continent.areaMap())
        } completion: { result in

        }
    }
    
    func prepareUI() {
        commonBackground()
        whiteNavBar()
        
        view.addSubview(bgHeaderImageV)
        var height = UIScreen.main.bounds.height - 270
        if isSmallScreen {
            height += 50
        }
        bgHeaderImageV.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        if selectModel != nil {
            bgHeaderImageV.image = UIImage(named: selectModel!.continent.areaMap())
        } else {
            bgHeaderImageV.image = UIImage(named: Continent.none.areaMap())
        }

        
        view.addSubview(lineItem)
        view.addSubview(tableView)
        lineItem.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(152)
            make.size.equalTo(CGSize(width: 100, height: 80))
        }
        let line = UIView(frame: CGRect(x: 35, y: 299, width: UIScreen.main.bounds.width - 70, height: 1))
        line.backgroundColor = UIColor.white
        line.alpha = 0.15
        view.addSubview(line)

        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(300)
            make.size.equalTo(CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 300))
        }
    }

    func request() {
        showHub()
        requestManger.request(url: api.getLineList) { success, result in
            self.hubHide()
            guard success else {
                self.showMessage(message: result.message)
                return
            }
            
            self.list =  result.data.arrayValue.map({ object in
                XSLineModel.init(json: object)
            })
            self.tableView.reloadData()

            guard self.list.count > 0 else {
                return
            }
            
            var i = 0
            let _ = (0..<self.list.count).filter { index in
                let model = self.list[index]
                if model.id == selectModel?.id {
                    i = index
                    return true
                } else {
                    return false
                }
            }
                
            self.tableView.selectRow(at: IndexPath(item: i, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.top)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension XSLineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:XSLineTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "XSLineTableViewCell", for: indexPath) as! XSLineTableViewCell
        let model = list[indexPath.row]
        
        let url = URL(string: model.icon)!
        cell.icon.kf.setImage(with: url)
        cell.icon.kf.setImage(with: url , placeholder: UIImage(named: "img_avatar_loading_def"))
//        cell.icon.image = UIImage(named: model.icon)
        cell.contentTitle.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = list[indexPath.row]
        selectModel = model
        selectModel?.archived()
        updateLineItemView()
        self.navigationController?.popViewController(animated: true)
    }
    
}
