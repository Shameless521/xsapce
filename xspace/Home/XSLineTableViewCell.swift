//
//  XSLineTableViewCell.swift
//  xspace
//
//  Created by Lendo on 2022/8/8.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit

enum LineStatus: Int {
    case good = 1,bad,busy
    func color() -> UIColor {
        switch self {
        case .good:
            return UIColor(red: 0.31, green: 0.77, blue: 0.24, alpha: 1)
        case .bad:
            return .red
        case .busy:
            return .gray
        }
    }
}
class XSLineTableViewCell: UITableViewCell {

    let icon:UIImageView = {
        let imgv = UIImageView()
        imgv.frame = CGRect(x: 35, y: 18, width: 40, height: 40)
        imgv.layer.cornerRadius = 20
        imgv.layer.masksToBounds = true
        imgv.layer.borderWidth = 2
        imgv.layer.borderColor = UIColor.white.cgColor
        return imgv
    }()
    
    let contentTitle: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 83, y: 25, width: 250, height: 25)
        label.text = "Britain"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    
    let statusCircle: UIView = {
        let view = UIView(frame: CGRect(x: UIScreen.main.bounds.width - 140, y: 35, width: 10, height: 10))
        view.layer.cornerRadius = 5;
        view.backgroundColor = LineStatus.good.color()
        return view
    }()
    
    let selectIcon:UIImageView = {
        let imgv = UIImageView()
        imgv.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 30, width: 20, height: 15)
        imgv.image = UIImage(named: "btn_line_arrow")
        return imgv
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectIcon.isHidden = !selected
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        contentView.backgroundColor = .clear
        contentView.addSubview(icon)
        contentView.addSubview(contentTitle)
        contentView.addSubview(selectIcon)
        contentView.addSubview(statusCircle)
        let line = UIView(frame: CGRect(x: 35, y: 74, width: UIScreen.main.bounds.width - 70, height: 1))
        line.backgroundColor = UIColor.white
        line.alpha = 0.15
        contentView.addSubview(line)
        selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
