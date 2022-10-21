//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by Monks on 2022/8/30.
//  Copyright © 2022 星舰. All rights reserved.
//

import NetworkExtension
let appGroup = "group.com.spacexspeed.quicks"

class PacketTunnelProvider: NEPacketTunnelProvider {
    private var tunnelFileDescriptor: Int32? {
        if #available(iOS 15, *) {
            var buf = [CChar](repeating: 0, count: Int(IFNAMSIZ))
            let utunPrefix = "utun".utf8CString.dropLast()
            return (0...1024).first { (_ fd: Int32) -> Bool in
            var len = socklen_t(buf.count)
            return getsockopt(fd, 2, 2, &buf, &len) == 0 && buf.starts(with: utunPrefix)
            }
        } else {
            return self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32
        }
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelNetworkSettings = createTunnelSettings()
        
//        SS = ss, 36.139.154.101, 21001, encrypt-method=aes-128-gcm, password=b8879c1c-634a-439e-bb30-4c11f0f5e8e8
//        - { name: '🇭🇰香港 03 | 直连', type: trojan, server: hk3.18878a24-49d8-4fb2-a1e3-f37dce7cf2a8.718be37e-804f-4696-968e-948430a90029.b1a0a095-825a-4ab6-8f9a-6cc9cb171dd2.yiyuan.cyou, port: 443, password: fd0cda89-f025-4625-b20d-9fbe3b6df014, udp: true, sni: 13-251-128-188.nhost.00cdn.com, skip-cert-verify: true }
        
//        EXTERNAL, site:geolocation-!cn, Fallback

        //Trojan = trojan, jp-1.speed-up.cc, 443, password=0D02DE44E0D130D7B3303D2BF27F8683
        //    - { name: '🇭🇰 Hong Kong 01', type: ss, server: 36.139.154.101, port: 21001, cipher: aes-128-gcm, password: b8879c1c-634a-439e-bb30-4c11f0f5e8e8, udp: true }
//        EXTERNAL, site:geolocation-!cn, Fallback
//        FINAL, Direct
        //
//        Trojan = trojan, hk3.18878a24-49d8-4fb2-a1e3-f37dce7cf2a8.718be37e-804f-4696-968e-948430a90029.b1a0a095-825a-4ab6-8f9a-6cc9cb171dd2.yiyuan.cyou, 443, password=fd0cda89-f025-4625-b20d-9fbe3b6df014, udp=true, sni=13-251-128-188.nhost.00cdn.com, skip-cert-verify=true
        //        GEOIP, us, Fallback
        var type = options!["type"] as! String //类型
        if type.count <= 0 {
             type = ""
        }
        var cipher = options!["cipher"] as! String //加密方式
        if cipher.count <= 0 {
            cipher = ""
        }
        var sni = options!["sni"] as! String
        if sni.count <= 0 {
            sni = ""
        }
        var tls = options!["tls"] as! String
        if tls.count <= 0 {
            tls = ""
        }
        var path = options!["path"] as! String
        if path.count <= 0 {
            path = ""
        }
        var password = options!["password"] as! String
        if password.count <= 0 {
            password = "123456"
        }
        var port = options!["port"] as! String
        if port.count <= 0 {
            port = "443"
        }
        var address = options!["address"] as! String
        if address.count <= 0 {
            address = "127.0.0.1"
        }
        
        var proxy =  ""
        var proxyName = ""
//        proxy = "SS = ss, 120.232.240.108, 21001, encrypt-method=aes-128-gcm, password=b8879c1c-634a-439e-bb30-4c11f0f5e8e8"
//        proxy = "Trojan = trojan, jp-2.speed-up.cc, 443, password=2a276da0-5600-c08a-26b0-82be885fcb02"

//        proxyName = "SS"
        switch type {
        case "ss":
            proxy = "SS = ss, \(address), \(port), encrypt-method=\(cipher), password=\(password)"
            proxyName = "SS"
            break
        case "trojan":
            proxy = "Trojan = trojan, \(address), \(port), password=\(password)"
            proxyName = "Trojan"
            break
        case "trojanTLS":
            proxy = "Trojan = trojan, \(address), \(port), password=\(password), sni=\(sni)"
            proxyName = "Trojan"
            break
        case "trojanWS":
            proxy = "Trojan = trojan, \(address), \(port), password=\(password), sni=\(sni), ws=true, ws-path=\(path) ,tls=\(tls)"
            proxyName = "Trojan"
            break
        case "vmess":
            proxy = "VMess = vmess, \(address), \(port), encrypt-method=\(cipher), password=\(password)"
            proxyName = "VMess"
            break
        case "vmesswss":
            proxy = "VMessWSS = vmess, \(address), \(port), encrypt-method=\(cipher), password=\(password), ws=true, ws-path=\(path) ,tls=\(tls)"
            proxyName = "VMess"
            break
        default:
            proxy = "Trojan = trojan, \(address), \(port), password=\(password)"
            proxyName = "Trojan"
            break
        }
        

        let conf = """
        [General]
        loglevel = trace
        dns-server = 223.5.5.5, 114.114.114.114
        tun-fd = REPLACE-ME-WITH-THE-FD

        [Proxy]
        Direct = direct
        Reject = reject
        \(proxy)

        [Proxy Group]
        Fallback = fallback , \(proxyName), interval=600, timeout=5
        
        
        [Rule]
        DOMAIN-KEYWORD, github, Fallback
        DOMAIN-KEYWORD, apple , Fallback
        DOMAIN-KEYWORD, amazon, Fallback
        FINAL, Direct
        """


        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            let tunFd = self?.tunnelFileDescriptor as! Int32 //self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32

            let confWithFd = conf.replacingOccurrences(of: "REPLACE-ME-WITH-THE-FD", with: String(tunFd))
            let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: appGroup)!.appendingPathComponent("running_config.conf")
            do {
                try confWithFd.write(to: url, atomically: false, encoding: .utf8)
            } catch {
                NSLog("fialed to write config file \(error)")
            }
            print("\(String(describing: error))")
            let path = url.absoluteString
            let start = path.index(path.startIndex, offsetBy: 7)
            let subpath = path[start..<path.endIndex]
            DispatchQueue.global(qos: .userInteractive).async {
                signal(SIGPIPE, SIG_IGN)
                leaf_run(0, String(subpath))
            }
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    func createTunnelSettings() -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.168.0.10")
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["192.168.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["223.5.5.5", "8.8.8.8"])
        newSettings.mtu = 1500
        return newSettings
    }
}
