//
//  ViewController.swift
//  PlayerVisual
//
//  Created by zm_iOS on 16/8/12.
//  Copyright © 2016年 zm_iOS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var player: PlayerVisual!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        player = PlayerVisual()
        player.addToViewController(self, toView: self.view)
        
        self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        player.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        player.playbackEdgeTriggered = false
        player.autoPlay = true
        player.playbackLoops = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = NSURL(string: "https://static.videezy.com/system/resources/previews/000/004/685/original/Geo_Glass_-_Slideshow.mp4")!
        player.setUrl(url)
    }
}

