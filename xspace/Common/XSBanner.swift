//
//  XSBanner.swift
//  xspace
//
//  Created by Lendo on 2022/8/3.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import SwiftyJSON
struct XSBanner {
    var icon: String
    var id: Int
    var name: String
    var type: Int
    var url: String
    
    init(json:JSON) {
        icon = json["icon"].stringValue
        name = json["name"].stringValue
        url = json["url"].stringValue
        id = json["id"].intValue
        type = json["type"].intValue
    }

}

