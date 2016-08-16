//
//  PlayerVisual.swift
//  PlayerVisual
//

import UIKit


// MARK: -

// MARK: PlayerVisualViewDelegate

@objc
public protocol PlayerVisualViewDelegate: NSObjectProtocol {
    
    func playerVisualViewStatuInitWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualViewReadyToPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualViewPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualViewPauseWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualViewStopWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualViewFailWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
    optional func playerVisualViewTappedShouldPlay(playerVisual: PlayerVisual) -> Bool
    
    optional func playerVisualViewSlidedShouldSeekToTime(playerVisual: PlayerVisual) -> NSTimeInterval
    
    // MARK: indictaor view
    
    func playerVisualIndictaorViewReady(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualIndictaorViewDelay(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualIndictaorViewError(playerVisual: PlayerVisual) -> UIView?
    
    // MARK: control bar
    
    func playerVisualControlBarHeight(playerVisual: PlayerVisual) -> CGFloat
    
    func playerVisualControlBarView(playerVisual: PlayerVisual) -> UIView?
    
    func playerVisualControlBarProgressPreferChange(playerVisual: PlayerVisual, currentTime: NSTimeInterval, maximumDuration: NSTimeInterval)
}


// MARK: -

// MARK: PlayerVisual

public class PlayerVisual: Player, PlayerDelegate {
    
    public weak var visualDelegate: PlayerVisualViewDelegate?
    public var autoPlay: Bool = true
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.visualDelegateDefault = PlayerVisualViewDefault()
        self.visualDelegate = self.visualDelegateDefault
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
        addLayerToView(nil)
        self.visualDelegate = nil
    }
    
    public override func addLayerToView(toView: UIView?) {
        super.addLayerToView(toView)
        
        if nil != toView {
            self.prepareComponent()
            
        } else {
            self.placeHolderView = nil
            self.controlBarView = nil
            self.indictaorView = nil
        }
    }
    
    
    // MARK: private
    
    private var visualDelegateDefault: PlayerVisualViewDefault? = nil {
        didSet {
            if self.visualDelegateDefault != oldValue {
                if nil != self.visualDelegateDefault && nil == self.visualDelegate {
                    self.visualDelegate = self.visualDelegateDefault
                }
            }
        }
    }
    
    private var placeHolderView: UIView? {
        didSet {
            if self.placeHolderView != oldValue {
                oldValue?.removeFromSuperview()
                
                if nil != self.placeHolderView {
                    self.view.addSubview(self.placeHolderView!)
                }
            }
        }
    }
    
    private var indictaorView: UIView? {
        didSet {
            if self.indictaorView != oldValue {
                oldValue?.removeFromSuperview()
                
                if nil != self.indictaorView {
                    self.view.addSubview(self.indictaorView!)
                }
            }
        }
    }
    
    private var controlBarView: UIView? {
        didSet {
            if self.controlBarView != oldValue {
                oldValue?.removeFromSuperview()
                
                if nil != self.controlBarView {
                    self.view.addSubview(self.controlBarView!)
                }
            }
        }
    }
    
    private func prepareComponent() {
        self.prepareInteractive()
        self.prepareHolderComponent()
        self.prepareControlBarComponent()
    }
    
    private func prepareInteractive() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func prepareHolderComponent() {
        self.placeHolderView = self.visualDelegate?.playerVisualViewStatuInitWithPlaceHolder(self)
    }
    
    private func prepareControlBarComponent() {
        // TODO: Add control bar
        let barHeight: CGFloat = self.visualDelegate?.playerVisualControlBarHeight(self) ?? 0
        if let bar = self.visualDelegate?.playerVisualControlBarView(self) {
            bar.frame = CGRectMake(0, self.view.bounds.height - barHeight, self.view.bounds.width, barHeight)
            self.controlBarView = bar
        }
    }
    
}

// MAKR: Callbacks

extension PlayerVisual {
    
    func playerViewTapped() {
        if .Failed != self.playbackState {
            if visualDelegate?.playerVisualViewTappedShouldPlay?(self) ?? false {
                if .Playing != self.playbackState {
                    self.playFromCurrentTime()
                }
                
            } else {
                if .Playing == self.playbackState {
                    self.pause()
                }
            }
        }
    }
    
    func playerViewSlided() {
        if .Failed != self.playbackState {
        }
    }
}

extension PlayerVisual {

    public func playerReady(player: Player) {
        let readyView = self.visualDelegate?.playerVisualViewReadyToPlayWithPlaceHolder(self)
        self.visualDelegate?.playerVisualControlBarProgressPreferChange(self, currentTime: player.currentTime, maximumDuration: player.maximumDuration)
        
        if self.autoPlay {
            player.playFromBeginning()
            
        } else {
            self.placeHolderView = readyView
        }
    }
    
    public func playerPlaybackStateDidChange(player: Player) {
        
        switch player.playbackState {
            
        case .Some(.Failed):
            self.placeHolderView = self.visualDelegate?.playerVisualViewFailWithPlaceHolder(self)
            
        case .Some(.Stopped):
            self.placeHolderView = self.visualDelegate?.playerVisualViewStopWithPlaceHolder(self)
            
        case .Some(.Paused):
            self.placeHolderView = self.visualDelegate?.playerVisualViewPauseWithPlaceHolder(self)
            
        case .Some(.Playing):
            self.placeHolderView = self.visualDelegate?.playerVisualViewPlayWithPlaceHolder(self)
            
        default:
            break
        }
    }
    
    public func playerBufferingStateDidChange(player: Player) {
        switch player.bufferingState {
        case .None:
            self.indictaorView = self.visualDelegate?.playerVisualIndictaorViewError(self)
            
        case .Some(.Delayed):
            self.indictaorView = self.visualDelegate?.playerVisualIndictaorViewDelay(self)
            
        case .Some(.Ready):
            self.indictaorView = self.visualDelegate?.playerVisualIndictaorViewReady(self)
            
        default:
            break
        }
    }
    
    public func playerCurrentTimeDidChange(player: Player) {
        self.visualDelegate?.playerVisualControlBarProgressPreferChange(self, currentTime: player.currentTime, maximumDuration: player.maximumDuration)
    }
    
    public func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    public func playerPlaybackDidEnd(player: Player) {
    }
    
    public func playerWillComeThroughLoop(player: Player) {
    }
}

extension PlayerView: PlayerVisualControlBarDelegate {
    
    func didSetToProgress(progress: Double) {
        
    }
}
