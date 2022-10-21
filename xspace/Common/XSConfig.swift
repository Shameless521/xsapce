//
//  XSConfig.swift
//  xspace
//
//  Created by Lendo on 2022/8/3.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit
import SwiftyJSON

struct XSConfig {
    var commitContent: String
    var commitDays, commitGive, id, intervals: Int
    var isCommit, isOpen, isWeal: Int
    var openIcon, openName, openURL, wealAddress: String
    var wealIcon, wealName: String

    init(json:JSON) {
        commitContent = json["commitContent"].stringValue
        commitDays = json["commitDays"].intValue
        commitGive = json["commitGive"].intValue
        id = json["id"].intValue
        intervals = json["intervals"].intValue
        isCommit = json["isCommit"].intValue
        isOpen = json["isOpen"].intValue
        isWeal = json["isWeal"].intValue
        openIcon = json["openIcon"].stringValue
        openName = json["openName"].stringValue
        openURL = json["openURL"].stringValue
        wealAddress = json["wealAddress"].stringValue
        wealIcon = json["wealIcon"].stringValue
        wealName = json["wealName"].stringValue
    }
}
