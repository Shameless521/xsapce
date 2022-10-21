//
//  XSSpeedManage.swift
//  xspace
//
//  Created by on 2022/9/7.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import NetworkExtension

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .invalid: return "Invalid"
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnecting: return "Disconnecting"
        case .reasserting: return "Reasserting"
        @unknown default:
            return ""
        }
    }
}

public class XSSpeedManage {
    public var manager = NEVPNManager.shared()
    
    private static var sharedVPNManager: XSSpeedManage = {
        return XSSpeedManage()
    }()
    
    public class func shared() -> XSSpeedManage {
        return sharedVPNManager
    }
    
    public init() {}
    
    public func loadVPNPreference(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences() { managers, error in
            guard let managers = managers, error == nil else {
                completion(error)
                return
            }
            
            if managers.count == 0 {
                let newManager = NETunnelProviderManager()
                newManager.protocolConfiguration = NETunnelProviderProtocol()
                newManager.localizedDescription = "星舰加速器"
                newManager.protocolConfiguration?.serverAddress = "星舰加速器"
                newManager.saveToPreferences { error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    newManager.loadFromPreferences { error in
                        self.manager = newManager
                        completion(nil)
                    }
                }
            } else {
                self.manager = managers[0]
                completion(nil)
            }
        }
    }
    
    public func enableVPNManager(completion: @escaping (Error?) -> Void) {
        manager.isEnabled = true
        manager.saveToPreferences { error in
            guard error == nil else {
                completion(error)
                return
            }
            self.manager.loadFromPreferences { error in
                completion(error)
            }
        }
    }

    
    func toggleVPNConnection(completion: @escaping (Error?) -> Void) {
        if self.manager.connection.status == .disconnected || self.manager.connection.status == .invalid {
            do {
                                
                guard selectModel != nil else {
                    return ;
                }
                let confAddress = selectModel?.address
                let confPost = selectModel?.port
                let confPassword = selectModel?.password
                let path = selectModel?.path
                let tls = selectModel?.tls
                let sni = selectModel?.sni
                let type = selectModel?.type
                let cipher = selectModel?.cipher
        
                
                var config1 = [String : Any]()
                config1["address"] = confAddress
                config1["port"] = String(confPost!)
                config1["password"] = confPassword
                config1["path"] = path
                config1["tls"] = tls
                config1["sni"] = sni
                config1["type"] = type
                config1["cipher"] = cipher
                
                print("\(config1)")
                try self.manager.connection.startVPNTunnel(options: config1 as? [String : NSObject])
            } catch {
                completion(error)
            }
        } else {
            self.manager.connection.stopVPNTunnel()
        }
    }
    
    func stopVPNConnection(completion: @escaping (Error?) -> Void) {
        
        self.manager.connection.stopVPNTunnel()
        
    }
    

}
