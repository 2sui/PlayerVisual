//
//  PlayerVisual.swift
//  PlayerVisual
//
//  Created by zm_iOS on 16/8/12.
//  Copyright © 2016年 zm_iOS. All rights reserved.
//

import UIKit


@objc
public protocol PlayerVisualDelegate: NSObjectProtocol {
    
}


public class PlayerVisual: Player, PlayerDelegate {
    
    public weak var playerDelegate: PlayerVisualDelegate?
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
}

extension PlayerVisual {

    public func playerReady(player: Player) {
        NSLog("\(#function)")
        
        player.playFromBeginning()
    }
    
    public func playerPlaybackStateDidChange(player: Player) {
        NSLog("\(#function) \(player.playbackState)")
    }
    
    public func playerBufferingStateDidChange(player: Player) {
        NSLog("\(#function) \(player.bufferingState)")
    }
    
    public func playerCurrentTimeDidChange(player: Player) {
        //        NSLog("\(#function) \(player.currentTime)")
    }
    
    public func playerPlaybackWillStartFromBeginning(player: Player) {
        NSLog("\(#function)")
    }
    
    public func playerPlaybackDidEnd(player: Player) {
        NSLog("\(#function) \(player.playbackState)")
    }
}
