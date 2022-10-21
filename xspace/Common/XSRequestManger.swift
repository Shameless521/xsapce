//
//  XSRequestManger.swift
//  xspace
//
//  Created by Lendo on 2022/8/2.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit
import CryptoSwift
import SwiftUI
import AVFoundation

var requestManger = XSRequestManger()

typealias ResultBlock = (Bool,BaseModel)->()

class XSRequestManger: NSObject {
    func request(url: XSUrl, resultBlock:@escaping ResultBlock) {
        let path = BaseURL + url.path
        var req = try! URLRequest(url: path, method: url.method, headers: commonHeaders)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        AF.request(req).response{respond in
            if respond.response?.statusCode != 200{
                let baseModel = BaseModel(message: respond.error?.asAFError?.localizedDescription, code: respond.response?.statusCode)
                resultBlock(false, baseModel)
            } else {
                self.handleData(data: respond.data, resultBlock: resultBlock)
                
            }
        }
    }
    
    func request(url: XSUrl, params:[String: Any], resultBlock:@escaping ResultBlock) {
        let path = BaseURL + url.path

        if url.method == .post {
            var req = try! URLRequest(url: path, method: url.method, headers: commonHeaders)
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let object: Data? = try? JSONSerialization.data(withJSONObject: params)
            req.httpBody = object
            AF.request(req).response{respond in
                if respond.response?.statusCode != 200{
                    let baseModel = BaseModel(message: respond.error?.asAFError?.localizedDescription, code: respond.response?.statusCode)
                    print("error post = \(url) + \(baseModel)")
                    resultBlock(false, baseModel)
                } else {
                    self.handleData(data: respond.data, resultBlock: resultBlock)
                }
            }
        } else {
            AF.request(path, method: url.method , parameters: params, headers: commonHeaders).response {
                respond in
                if respond.response?.statusCode != 200{
                    let baseModel = BaseModel(message: respond.error?.asAFError?.localizedDescription, code: respond.response?.statusCode)
                    print("error get = \(url) + \(baseModel)")
                    resultBlock(false, baseModel)
                } else {
                    self.handleData(data: respond.data, resultBlock: resultBlock)
                }
            }
        }
      
    }
    
    func handleData(data: Any?, resultBlock:@escaping ResultBlock )  {
        let baseModel = decodeToBaseModel(data: data)
        print("\(baseModel)")
        if baseModel.code == 200 {
            resultBlock(true, baseModel)
        } else {
            resultBlock(false, baseModel)
        }
    }
    
    func decodeToBaseModel(data: Any?) -> BaseModel {
        guard let _ = data else {
            return BaseModel()
        }
        do {
            let aes = try! AES(key: Array("siweikeji8888888".utf8), blockMode: ECB(), padding: .pkcs7)
            var jsonString = data as? String
            let jsonData = data as? Data
            if jsonString == nil && jsonData != nil {
                jsonString = String(data: jsonData!, encoding: .utf8)
            }
            if jsonString != nil {
                let decryptString = try? jsonString!.decryptBase64ToString(cipher: aes)
                guard let _ = decryptString else {
                    throw decryptError.emptyKey
                }
                return BaseModel.init(json:JSON(parseJSON:decryptString!))
            } else {
                throw decryptError.other
            }
        }
        catch {
            return BaseModel(message: error.localizedDescription, code: 10001)
        }
    }
    
   
}

enum decryptError : Error {
    case emptyKey
    case other
}

extension decryptError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyKey:
            return "emptyKey"
        case.other:
            return "似乎服务端返回的数据出错了~~"
        }
    }
}
