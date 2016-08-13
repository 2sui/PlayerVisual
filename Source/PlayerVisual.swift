//
//  PlayerVisual.swift
//  PlayerVisual
//

import UIKit


@objc
public protocol PlayerVisualIndictaorViewDelegate: NSObjectProtocol {
    // first add to layer
    func indictaorViewStatuInit()
    
    // video asset ready to play
    func indictaorViewReadyToPlay()
    
    func indictaorViewPlay()
    
    func indictaorViewPause()
    
    func indictaorViewStop()
    
    func indictaorViewFail()
    
    func indictaorViewBufferReady()
    
    func indictaorViewBufferDelay()
    
    func indictaorViewBufferError()
}


@objc
public protocol PlayerVisualDelegate: NSObjectProtocol {
}


public class PlayerVisual: Player, PlayerDelegate {
    
    public weak var playerDelegate: PlayerVisualDelegate?
    public var indictaorView: PlayerVisualIndictaorViewDelegate? {
        didSet {
            if !(indictaorView is UIView) {
                indictaorView = nil
            }
        }
    }
    
    public var autoPlay: Bool = true
    
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
    
    deinit {
        playerDelegate = nil
        indictaorView = nil
    }
    
    public override func addLayerToView(toView: UIView?) {
        super.addLayerToView(toView)
        
        if nil != toView {
            self.prepareComponent()
            
        } else {
            (self.indictaorView as? UIActivityIndicatorView)?.removeFromSuperview()
        }
    }
    
}

extension PlayerVisual {
    
    private func prepareComponent() {
        self.prepareIndictaorComponent()
    }
    
    private func prepareIndictaorComponent() {
        if nil == self.indictaorView {
            self.indictaorView = PlayerVisualIndictaorView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
            (self.indictaorView! as! UIView).center = self.view.center
        }
        
        if nil != self.indictaorView {
            self.view.addSubview(self.indictaorView! as! UIView)
        }
        
        self.indictaorView?.indictaorViewStatuInit()
    }
    
}

extension PlayerVisual {

    public func playerReady(player: Player) {
        
        if self.autoPlay {
            player.playFromBeginning()
            
        } else {
            self.indictaorView?.indictaorViewReadyToPlay()
        }
    }
    
    public func playerPlaybackStateDidChange(player: Player) {
        
        switch player.playbackState {
            
        case .Some(.Failed):
            self.indictaorView?.indictaorViewFail()
            
        case .Some(.Stopped):
            self.indictaorView?.indictaorViewStop()
            
        case .Some(.Paused):
            self.indictaorView?.indictaorViewPause()
            
        case .Some(.Playing):
            self.indictaorView?.indictaorViewPlay()
            
        default:
            break
        }
    }
    
    public func playerBufferingStateDidChange(player: Player) {
        switch player.bufferingState {
        case .None:
            self.indictaorView?.indictaorViewBufferError()
            
        case .Some(.Delayed):
            self.indictaorView?.indictaorViewBufferDelay()
            
        case .Some(.Ready):
            self.indictaorView?.indictaorViewBufferReady()
            
        default:
            break
        }
    }
    
    public func playerCurrentTimeDidChange(player: Player) {
    }
    
    public func playerPlaybackWillStartFromBeginning(player: Player) {
        NSLog("\(#function)")
    }
    
    public func playerPlaybackDidEnd(player: Player) {
        NSLog("\(#function)")
    }
}
