//
//  ViewController.swift
//  UDPServer
//
//  Created by 村上晋太郎 on 2016/02/04.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UDPDelegate {
    
    let udp = UDP()
    
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    var outputBuffer = AVAudioPCMBuffer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord,
            withOptions: AVAudioSessionCategoryOptions.AllowBluetooth)
        
        try! session.setActive(true)
        
        // Do any additional setup after loading the view, typically from a nib.
        udp.delegate = self
        print(udp.getIPAddress())
        udp.startServerOnPort(5000)
        
        
        let bufferSize = UInt32(16537) // 決め打ち。ここを動的に変更できるようにはしたい。
//        let bufferSize = UInt32(1024 * 2) // 決め打ち。ここを動的に変更できるようにはしたい。
        outputBuffer = AVAudioPCMBuffer(PCMFormat: player.outputFormatForBus(0), frameCapacity: bufferSize)
        outputBuffer.frameLength = bufferSize

        
        engine.attachNode(player)
        engine.connect(player, to: engine.mainMixerNode, format: player.outputFormatForBus(0))
        
        engine.prepare()
        try! engine.start()
        
        player.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UDPDelegate
    
    var bufferOffset = 0
    
    func udp(udp: UDP!, didReceiveData data: NSData!, fromAddress addr: NSData!) {
        print("receive")
        
        let count = Int(data.length / sizeof(Float))
        
        var received = [Float](count: count, repeatedValue: 0)
        data.getBytes(&received, length: data.length)
        
        let bus = 0
        print("data length: \(count)")
        
        let step = Int(self.engine.mainMixerNode.outputFormatForBus(bus).channelCount)
        
        var i = 0
        
        while i < count && i + bufferOffset < Int(self.outputBuffer.frameLength) {
            let index = i + bufferOffset
            self.outputBuffer.floatChannelData.memory[index] = received[i]
            i += step
        }
        
        print("buffer offset: \(bufferOffset)")
        
        bufferOffset = bufferOffset + i
        
        if bufferOffset >= Int(self.outputBuffer.frameLength) {
            print("schedule")
            self.player.scheduleBuffer(self.outputBuffer, atTime: nil, options: .Loops, completionHandler: nil)
            
            var index = 0
            while i < count {
                self.outputBuffer.floatChannelData.memory[index] = received[i]
                i += step
                index += step
            }
            bufferOffset = index
        }
        
//        for var i = 0; i < received.count; i += step {
//            self.outputBuffer.floatChannelData.memory[i] = received[i]
//        }
//        self.player.scheduleBuffer(self.outputBuffer, atTime: nil, options: .Interrupts, completionHandler: nil)
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

