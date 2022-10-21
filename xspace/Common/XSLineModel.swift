//
//  XSLineModel.swift
//  xspace
//
//  Created by Lendo on 2022/8/3.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import SwiftyJSON
// MARK: - 选中的线路
var selectModel: XSLineModel?

//0 亚洲 1 北美 2 南美 3 欧洲 4 非洲 5 大洋洲 6 南极洲
enum Continent: Int {
    case Asian = 0,NorthAmerica,SouthAmerica,Europe,Africa,Oceania,Antarctica,none
    
    func areaMap() -> String {
        switch self {
        case .Asian:
            return "Asian"
        case .NorthAmerica:
            return "NorthAmerica"
        case .SouthAmerica:
            return "SouthAmerica"
        case .Europe:
            return "Europe"
        case .Africa:
            return "Africa"
        case .Oceania:
            return "Oceania"
        case .Antarctica:
            return "img_home_map"
        case .none:
            return "img_home_map"
        }
    }
}

class XSLineModel: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
    
    var address, icon: String
    var id: Int
    var name, password, path, type, cipher: String
    var port: String
    var sni: String
    var tls: String
    var continent: Continent
    
    init(json:JSON) {
        address = json["address"].stringValue
        icon = json["icon"].stringValue
        name = json["name"].stringValue
        password = json["password"].stringValue
        path = json["path"].stringValue
        sni = json["sni"].stringValue
        type = json["type"].stringValue
        cipher = json["cipher"].stringValue
        
        id = json["id"].intValue
        port = json["port"].stringValue
        tls = json["tls"].stringValue
        continent = Continent(rawValue: json["continents"].intValue) ?? .Asian
    }
    
    func archived() {
        let archive = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        if let _ = archive {
            guard let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last else { return  }
            guard let url =  URL(string: "file://" + path)?.appendingPathComponent("/lineModel") else {
                return
            }
            do {
                try archive?.write(to: url)
            } catch let error as NSError {
                print("\(error)")
            }
        }
    }
    
    static func unArchived() {
        guard let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last else { return  }
        guard let url =  URL(string: "file://" + path)?.appendingPathComponent("/lineModel") else { return }
        
        if let data = try? Data(contentsOf:url){
            do {
                let user = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? XSLineModel
//                let user = try NSKeyedUnarchiver.unarchivedObject(ofClass: XSLineModel.self, from: data)
                selectModel = user
            } catch {
                fatalError("Can't encode data: \(error)")
            }
        }
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(address, forKey: "address")
        coder.encode(icon, forKey: "icon")
        coder.encode(name, forKey: "name")
        coder.encode(password, forKey: "password")
        coder.encode(path, forKey: "path")
        coder.encode(sni, forKey: "sni")
        coder.encode(tls, forKey: "tls")
        coder.encode(port, forKey: "port")
        coder.encode(type, forKey: "type")
        coder.encode(cipher, forKey: "cipher")
        let cont = Continent.RawValue()
        coder.encode(cont, forKey: "continents")
    }
    
    required init?(coder: NSCoder) {
        
        address = coder.decodeObject(forKey: "address") as? String  ?? ""
        icon = coder.decodeObject(forKey: "icon") as? String  ?? ""
        name = coder.decodeObject(forKey: "name") as? String  ?? ""
        password = coder.decodeObject(forKey: "password") as? String  ?? ""
        path = coder.decodeObject(forKey: "path") as? String  ?? ""
        sni = coder.decodeObject(forKey: "sni") as? String  ?? ""
        type = coder.decodeObject(forKey: "type") as? String  ?? ""
        cipher = coder.decodeObject(forKey: "cipher") as? String  ?? ""
        
        tls = coder.decodeObject(forKey: "tls") as? String  ?? ""
        port = coder.decodeObject(forKey: "port") as? String  ?? ""
        
//        tls = coder.decodeInteger(forKey: "tls")
//        port = coder.decodeInteger(forKey: "port")
        id = coder.decodeInteger(forKey: "id")
//        continent = coder.decodeInteger(forKey: "continents")

        let i = coder.decodeInteger(forKey: "continents")
        continent = Continent(rawValue: i) ?? .Asian
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let obj = XSLineModel(json: JSON())
        return obj
    }
}
