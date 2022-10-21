//
//  XSBaseModel.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BaseModel {
    var code: Int
    var data: JSON
    var message: String
    
    init(json:JSON) {
        code = json["code"].intValue
        data = json["data"]
        message = json["message"].stringValue
    }
    
    init() {
        code = 10000
        data = JSON()
        message = "数据格式匹配出错啦~~"
    }
    
    init(message:String? , code: Int?){
        self.code = code ?? -1
        self.message = message ?? "未知错误"
        data = JSON()
    }
    
}
