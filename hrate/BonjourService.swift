//
//  BonjourService.swift
//  hrate
//
//  Created by Anselm Joseph on 15/06/21.
//

import Foundation

class BonjourService: NSObject, ObservableObject {
    
    @Published var searching = false
    @Published var foundService = false
    @Published var serviceURL: String! = nil {
        didSet {
            serviceUrlDidChange(serviceURL)
        }
    }
    @Published var error: String! = nil
    
    private let bonjourBrowser = NetServiceBrowser()
    private var discoveredService: NetService?
    
    var serviceUrlDidChange: (_ URL: String?) -> Void = {_ in }
    
    override init() {
        super.init()
        bonjourBrowser.delegate = self
    }
    
    func start() {
        print("Searching for Bonjour services")
        searching = true
        
        DispatchQueue(label: "bonjour-queue").async {
            self.bonjourBrowser.schedule(in: RunLoop.current, forMode: .default)
            self.bonjourBrowser.searchForServices(ofType: "_http._tcp.", inDomain: "local")
            RunLoop.current.run()
        }
    }
    
    func stop() {
        searching = false
        self.bonjourBrowser.stop()
    }
}

extension BonjourService: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if (service.name == "hrate_server") {
            print("Found \(service.name)")
            discoveredService = service
            discoveredService?.delegate = self
            discoveredService?.resolve(withTimeout: 10)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Did not search", errorDict)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Bonjour stopped")
        self.discoveredService = nil
        DispatchQueue.main.async {
            self.foundService = false
            self.serviceURL = nil
        }
    }
}

extension BonjourService: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("resolved address", sender.name)
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = sender.addresses?.first else { return }
        data.withUnsafeBytes { ptr in
            guard let sockaddr_ptr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                print("Error")
                return
            }
            let sockaddr = sockaddr_ptr.pointee
            guard getnameinfo(sockaddr_ptr, socklen_t(sockaddr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        let ipAddress = String(cString:hostname)
        
        DispatchQueue.main.async {
            self.foundService = true
            self.serviceURL = "\(ipAddress):\(sender.port)"
            print("service url", self.serviceURL!)
        }
    }
    
    func netServiceDidStop(_ sender: NetService) {
        print("Resolve stopped", sender.name)
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("did not resolve", sender.name, errorDict)
        
        DispatchQueue.main.async {
            self.foundService = false
            self.serviceURL = nil
            self.error = "Unable to resolve IP"
        }
    }
}
