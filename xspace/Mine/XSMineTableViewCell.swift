//
//  XSMineTableViewCell.swift
//  xspace
//
//  Created by Lendo on 2022/8/8.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit

class XSMineTableViewCell: UITableViewCell {

    let contentTitle: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 30, y: 12, width: 250, height: 22)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()


    let rightIcon:UIImageView = {
        let imgv = UIImageView()
        imgv.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 30, width: 7, height: 13)
        imgv.image = UIImage(named: "btn_mine_serve")
        return imgv
    }()
    
    let switchBtn:UISwitch = {
        let sw = UISwitch()
        sw.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        return sw
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(contentTitle)
        contentView.addSubview(rightIcon)
        contentView.addSubview(switchBtn)
        
        let line = UIView()
        line.backgroundColor = HexRGBAlpha(0xffffff, 0.15)
        contentView.addSubview(line)
        selectionStyle = .none
        line.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.equalTo(-1)
            make.height.equalTo(1)
        }
        
        rightIcon.snp.makeConstraints { make in
            make.right.equalTo(-30)
            make.centerY.equalToSuperview()
            make.height.equalTo(13)
            make.width.equalTo(7)
        }
        
        switchBtn.snp.makeConstraints { make in
            make.right.equalTo(-30)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(44)

        }
        
        switchBtn.isHidden = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
