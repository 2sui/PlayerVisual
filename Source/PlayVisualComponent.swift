//
//  PlayVisualComponent.swift
//  PlayerVisual
//

import UIKit
import YYImage


// MAKR: -

// MARK: PlayerVisualIndictaor

public class PlayerVisualIndictaor: NSObject, PlayerVisualIndictaorViewDelegate {
    
    override init() {
        super.init()
        self.prepareIndictaorViews()
    }

    // MARK: private 
    
    private let playIcon = YYAnimatedImageView(frame: CGRectMake(0, 0, 100, 100))
    private let stopIcon = YYAnimatedImageView(frame: CGRectMake(0, 0, 100, 100))
    private let initIcon = YYAnimatedImageView(frame: CGRectMake(0, 0, 95, 41))
    private let loadingIcon = YYAnimatedImageView(frame: CGRectMake(0, 0, 125, 47))
    
    private func prepareIndictaorViews() {
        if let path = NSBundle.mainBundle().pathForResource("play", ofType: "png") {
            let image = YYImage(contentsOfFile: path)
            playIcon.image = image
        }
        if let path = NSBundle.mainBundle().pathForResource("bufferLoading", ofType: "gif") {
            let image = YYImage(contentsOfFile: path)
            loadingIcon.image = image
        }
        if let path = NSBundle.mainBundle().pathForResource("wait", ofType: "png") {
            let image = YYImage(contentsOfFile: path)
            initIcon.image = image
        }
        if let path = NSBundle.mainBundle().pathForResource("stop", ofType: "png") {
            let image = YYImage(contentsOfFile: path)
            stopIcon.image = image
        }
        
        playIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        loadingIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        initIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        stopIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
    }
}

extension PlayerVisualIndictaor {
    // first add to layer
    public func indictaorViewStatuInit(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        self.initIcon.center = playerView.center
        return self.initIcon
    }
    
    // video asset ready to play
    public func indictaorViewReadyToPlay(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        self.playIcon.center = playerView.center
        return self.playIcon
    }
    
    public func indictaorViewPlay(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        return nil
    }
    
    public func indictaorViewPause(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        self.stopIcon.center = playerView.center
        return self.stopIcon
    }
    
    public func indictaorViewStop(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        self.playIcon.center = playerView.center
        return self.playIcon
    }
    
    public func indictaorViewFail(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        self.stopIcon.center = playerView.center
        return self.stopIcon
    }
    
    public func indictaorViewBufferReady(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        return nil
    }
    
    public func indictaorViewBufferDelay(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        self.loadingIcon.center = playerView.center
        return self.loadingIcon
    }
    
    public func indictaorViewBufferError(playerView: UIView) -> UIView? {
        NSLog("\(#function)")
        return nil
    }
}


// MARK: -

// MAKR: 

class PlayerVisualControlBar: UIView {
    
}

