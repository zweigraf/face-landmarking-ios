//
//  ViewController.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let sessionHandler = SessionHandler()
    
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        sessionHandler.openSession()
        

//        let layer = sessionHandler.layer
//        layer.frame = preview.bounds
//
//        preview.layer.addSublayer(layer)
        
        
        let newFileName = "left-mod.jpg"
        let tmpPath = NSTemporaryDirectory() as NSString
        let path = tmpPath.stringByAppendingPathComponent(newFileName)
        
        let image = UIImage(contentsOfFile: path)
        
        imageView.image = image

        
        view.layoutIfNeeded()

    }

}

