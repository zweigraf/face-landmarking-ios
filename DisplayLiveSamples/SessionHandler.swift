//
//  SessionHandler.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import AVFoundation

class SessionHandler : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session = AVCaptureSession()
    let layer = AVSampleBufferDisplayLayer()
    let sampleQueue = dispatch_queue_create("com.zweigraf.DisplayLiveSamples.sampleQueue", DISPATCH_QUEUE_SERIAL)
    
    override init() {
        super.init()
    }
    
    func openSession() {
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sampleQueue)
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input = try! AVCaptureDeviceInput(device: device)
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
       
        session.startRunning()
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        print("samplebuffer")
    }
}
