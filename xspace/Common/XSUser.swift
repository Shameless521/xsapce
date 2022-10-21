//
//  XSUser.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import SwiftyJSON
var currentUser:XSUser?

class XSUser:NSObject, NSCoding , NSSecureCoding{
    static var supportsSecureCoding: Bool {
        return true
    }
    
    var exprieTime: String //过期时间
    var id: Int
    var isVip:String // 是否是vip
    var imageURL, phone, userCode: String
    var userName: String
    
    init(json:JSON) {
         exprieTime = json["exprieTime"].stringValue //过期时间
         id = json["id"].intValue
         isVip = json["isVip"].stringValue // 是否是vip
         imageURL = json["imageURL"].stringValue
         phone = json["phone"].stringValue
         userCode = json["userCode"].stringValue
         userName = json["userName"].stringValue
    }
    
    
    func archived() {
        let archive = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        if let _ = archive {
            guard let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last else { return  }
            guard let url =  URL(string: "file://" + path)?.appendingPathComponent("/userInfo") else {return}
            do {
                try archive?.write(to: url)
            } catch let error as NSError {
                print("\(error)")
            }
        }
    }
    
    static func unArchived() {
        guard let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last else { return  }
        guard let url =  URL(string: "file://" + path)?.appendingPathComponent("/userInfo") else { return }
        
        
//
//        do {
//            let data = try Data(contentsOf: url)
//            let user = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? XSUser
//            currentUser = user
//        } catch {
//            fatalError("Can't encode data: \(error)")
//        }
//
        if let data = try? Data(contentsOf:url){
            do {
//                let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? XSUser
                let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? XSUser

                currentUser = user
            } catch {
                fatalError("Can't encode data: \(error)")
            }
        }
    }
    
    static func clearUserArchive() {
        guard let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last else { return  }
        guard let url =  URL(string: "file://" + path)?.appendingPathComponent("/userInfo") else {return}
        do {
            try FileManager().removeItem(at: url)
        } catch let error as NSError {
            print("\(error)")
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(exprieTime, forKey: "exprieTime")
        coder.encode(isVip, forKey: "isVip")
        coder.encode(imageURL, forKey: "imageURL")
        coder.encode(phone, forKey: "phone")
        coder.encode(userCode, forKey: "userCode")
        coder.encode(userName, forKey: "userName")
    }
    
    required init?(coder: NSCoder) {
        exprieTime = coder.decodeObject(forKey: "exprieTime") as? String  ?? ""
        id = coder.decodeInteger(forKey: "id")
        isVip = coder.decodeObject(forKey: "isVip") as? String  ?? ""
        imageURL = coder.decodeObject(forKey: "imageURL") as? String  ?? ""
        phone = coder.decodeObject(forKey: "phone") as? String  ?? ""
        userCode = coder.decodeObject(forKey: "userCode") as? String  ?? ""
        userName = coder.decodeObject(forKey: "userName") as? String  ?? ""
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let obj = XSUser(json: JSON())
        return obj
    }

}

