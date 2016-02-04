//
//  ViewController.swift
//  UDPServer
//
//  Created by 村上晋太郎 on 2016/02/04.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UDPDelegate {
    
    let udp = UDP()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        udp.delegate = self
        print(udp.getIPAddress())
        udp.startServerOnPort(5000)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UDPDelegate
    
    func udp(udp: UDP!, didReceiveData data: NSData!, fromAddress addr: NSData!) {
        print("receive")
        print(data)
    }
    
    func udp(udp: UDP!, didReceiveError error: NSError!) {
        print("error")
        print(error.description)
    }
    
    func udp(udp: UDP!, didSendData data: NSData!, toAddress addr: NSData!) {
        print("did send data")
        print("data: \(String(data: data, encoding: NSUTF8StringEncoding)))")
    }
    
    func udp(udp: UDP!, didStopWithError error: NSError!) {
        print("did stop")
        print(error.description)
    }
    
    func udp(udp: UDP!, didStartWithAddress address: NSData!) {
        print("start")
    }
    
    func udp(udp: UDP!, didFailToSendData data: NSData!, toAddress addr: NSData!, error: NSError!) {
        print("fail")
        print(error.description)
    }
    
}

