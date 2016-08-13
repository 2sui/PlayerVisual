//
//  PlayerVisual.swift
//  PlayerVisual
//

import UIKit


// MARK: -

// MARK: PlayerVisualIndictaorViewDelegate

@objc
public protocol PlayerVisualIndictaorViewDelegate: NSObjectProtocol {
    // first add to layer
    func indictaorViewStatuInit(playerView: UIView) -> UIView?
    
    // video asset ready to play
    func indictaorViewReadyToPlay(playerView: UIView) -> UIView?
    
    func indictaorViewPlay(playerView: UIView) -> UIView?
    
    func indictaorViewPause(playerView: UIView) -> UIView?
    
    func indictaorViewStop(playerView: UIView) -> UIView?
    
    func indictaorViewFail(playerView: UIView) -> UIView?
    
    func indictaorViewBufferReady(playerView: UIView) -> UIView?
    
    func indictaorViewBufferDelay(playerView: UIView) -> UIView?
    
    func indictaorViewBufferError(playerView: UIView) -> UIView?
}


@objc
public protocol PlayerVisualControlBarDelegate: NSObjectProtocol {
}


// MARK: -

// MARK: PlayerVisual

public class PlayerVisual: Player, PlayerDelegate {
    
    public weak var controlBarDelegate: PlayerVisualControlBarDelegate?
    public weak var indictaorViewDelegate: PlayerVisualIndictaorViewDelegate?
    public var autoPlay: Bool = true
    
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.indictaor = PlayerVisualIndictaor()
        self.indictaorViewDelegate = self.indictaor
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
        controlBarDelegate = nil
        indictaorViewDelegate = nil
    }
    
    public override func addLayerToView(toView: UIView?) {
        super.addLayerToView(toView)
        
        if nil != toView {
            self.prepareComponent()
            
        } else {
            self.indictaorView = nil
        }
    }
    
    
    // MARK: private
    private var indictaor: PlayerVisualIndictaorViewDelegate?
    private var indictaorView: UIView? {
        didSet {
            if indictaorView != oldValue {
                oldValue?.removeFromSuperview()
                
                if nil != indictaorView {
                    self.view.addSubview(indictaorView!)
                }
            }
        }
    }
    private var controlBar: PlayerVisualControlBarDelegate?
    private var controlBarView: UIView? {
        didSet {
            
        }
    }
    
    private func prepareComponent() {
        self.prepareInteractive()
        self.prepareControlBarComponent()
        self.prepareIndictaorComponent()
    }
    
    private func prepareInteractive() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func prepareIndictaorComponent() {
        self.indictaorView = self.indictaorViewDelegate?.indictaorViewStatuInit(self.view)
    }
    
    private func prepareControlBarComponent() {
        // TODO: Add control bar
    }
    
}

// MAKR: Callbacks

extension PlayerVisual {
    
    func playerViewTapped() {
        if .Failed != self.playbackState {
            if .Playing == self.playbackState {
                self.pause()
                
            } else {
                self.playFromCurrentTime()
            }
        }
    }
}

extension PlayerVisual {

    public func playerReady(player: Player) {
        
        if self.autoPlay {
            player.playFromBeginning()
            
        } else {
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewReadyToPlay(self.view)
        }
    }
    
    public func playerPlaybackStateDidChange(player: Player) {
        
        switch player.playbackState {
            
        case .Some(.Failed):
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewFail(self.view)
            
        case .Some(.Stopped):
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewStop(self.view)
            
        case .Some(.Paused):
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewPause(self.view)
            
        case .Some(.Playing):
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewPlay(self.view)
            
        default:
            break
        }
    }
    
    public func playerBufferingStateDidChange(player: Player) {
        switch player.bufferingState {
        case .None:
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewBufferError(self.view)
            
        case .Some(.Delayed):
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewBufferDelay(self.view)
            
        case .Some(.Ready):
            self.indictaorView = self.indictaorViewDelegate?.indictaorViewBufferReady(self.view)
            
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
