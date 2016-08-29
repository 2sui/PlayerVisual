//
//  PlayerVisual.swift
//  PlayerVisual
//

import UIKit
import CoreMedia
import QPlayer


// MARK: -

// MARK: PlayerVisualViewDelegate

@objc
public protocol PlayerVisualDelegate: NSObjectProtocol {
    
     func playerVisualStatuInitWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
     func playerVisualReadyToPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
     func playerVisualPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
     func playerVisualPauseWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
     func playerVisualStopWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
     func playerVisualFailWithPlaceHolder(playerVisual: PlayerVisual) -> UIView?
    
    // MARK: gesture
    
     func playerVisualVideoSizeChange(playerVisual: PlayerVisual, size: CGSize)
    
     func playerVisualTappedShouldPlay(playerVisual: PlayerVisual) -> Bool
    
     func playerVisualSlidedSeekTimeWillSetWithInterval(playerVisual: PlayerVisual) -> Int64
    
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

public class PlayerVisual: QPlayer, QPlayerDelegate {
    
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
        self.controlBarView = nil
        self.placeHolderView = nil
        self.indictaorView = nil
        self.visualDelegate = nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.continuePlayAfterEnterForeground = false
        self.prepareInteractive()
        self.prepareControlBarComponent()
        self.prepareHolderComponent()
    }
    
    // MARK: - Public
    
    public weak var visualDelegate: PlayerVisualDelegate?
    public var autoPlay: Bool = true
    
    public override func addLayerToView(toView: UIView?) {
        super.addLayerToView(toView)
        
        if nil != toView {
            self.view.frame = CGRectMake(0, 0, toView!.bounds.width, toView!.bounds.height)
            self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
            
        } else {
            self.placeHolderView = nil
            self.indictaorView = nil
        }
    }
    
    
    // MARK: - Private
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
    
    private func prepareInteractive() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerVisualTappedInView))
        let leftSlideGesture = UISwipeGestureRecognizer(target: self, action: #selector(playerVisualSlideInView))
        let rightSlideGesture = UISwipeGestureRecognizer(target: self, action: #selector(playerVisualSlideInView))
        leftSlideGesture.direction = .Left
        rightSlideGesture.direction = .Right
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(leftSlideGesture)
        self.view.addGestureRecognizer(rightSlideGesture)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func prepareHolderComponent() {
        self.placeHolderView = self.visualDelegate?.playerVisualStatuInitWithPlaceHolder(self)
    }
    
    private func prepareControlBarComponent() {
        if let barHeight: CGFloat = self.visualDelegate?.playerVisualControlBarHeight(self) ?? 0, bar = self.visualDelegate?.playerVisualControlBarView(self) {
            bar.frame = CGRectMake(0, self.view.bounds.height - barHeight, self.view.bounds.width, barHeight)
            self.controlBarView = bar
        }
    }
    
}

// MAKR: Callbacks

extension PlayerVisual {
    
    func playerVisualTappedInView(sender: UITapGestureRecognizer) {
        if .Failed != self.playbackState {
            if self.visualDelegate?.playerVisualTappedShouldPlay(self) ?? false {
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
    
    func playerVisualSlideInView(sender: UISwipeGestureRecognizer) {
        if .Failed != self.playbackState {
            let isRight: Bool
            switch sender.direction {
            case UISwipeGestureRecognizerDirection.Right:
                isRight = true
            case UISwipeGestureRecognizerDirection.Left:
                isRight = false
            default:
                return
            }
            
            guard let timeval = self.visualDelegate?.playerVisualSlidedSeekTimeWillSetWithInterval(self) else {
                return
            }
            
            var tval = isRight ? CMTimeAdd(self.currentCMTime, CMTimeMake(Int64(self.currentCMTime.timescale) * timeval, self.currentCMTime.timescale)) : CMTimeSubtract(self.currentCMTime, CMTimeMake(Int64(self.currentCMTime.timescale) * timeval, self.currentCMTime.timescale))
            
            if CMTIME_IS_INVALID(tval) {
                tval = kCMTimeZero
            }
            
            self.seekToTime(tval, toleranceBefore: CMTimeMake(1,4), toleranceAfter: CMTimeMake(1,4), completionHandler: nil)
        }
    }
}

extension PlayerVisual {

    public func playerReady(player: QPlayer) {
        self.visualDelegate?.playerVisualVideoSizeChange(self, size: self.naturalSize)
        self.visualDelegate?.playerVisualControlBarProgressPreferChange(self, currentTime: player.currentTime, maximumDuration: player.maximumDuration)
        let readyView = self.visualDelegate?.playerVisualReadyToPlayWithPlaceHolder(self)
        
        if self.autoPlay && 0 == self.currentTime {
            player.playFromBeginning()
            
        } else {
            self.placeHolderView = readyView
        }
    }
    
    public func playerPlaybackStateDidChange(player: QPlayer) {
        
        switch player.playbackState {
            
        case .Failed:
            self.placeHolderView = self.visualDelegate?.playerVisualFailWithPlaceHolder(self)
            
        case .Stopped:
            self.placeHolderView = self.visualDelegate?.playerVisualStopWithPlaceHolder(self)
            
        case .Paused:
            self.placeHolderView = self.visualDelegate?.playerVisualPauseWithPlaceHolder(self)
            
        case .Playing:
            self.placeHolderView = self.visualDelegate?.playerVisualPlayWithPlaceHolder(self)
        }
    }
    
    public func playerBufferingStateDidChange(player: QPlayer) {
        switch player.bufferingState {
        case .Delayed:
            self.indictaorView = self.visualDelegate?.playerVisualIndictaorViewDelay(self)
            
        case .Ready:
            self.indictaorView = self.visualDelegate?.playerVisualIndictaorViewReady(self)
            
        default:
            break
        }
    }
    
    public func playerCurrentTimeDidChange(player: QPlayer) {
        self.visualDelegate?.playerVisualControlBarProgressPreferChange(self, currentTime: player.currentTime, maximumDuration: player.maximumDuration)
    }
    
    public func playerPlaybackWillStartFromBeginning(player: QPlayer) {
    }
    
    public func playerPlaybackDidEnd(player: QPlayer) {
    }
    
    public func playerWillComeThroughLoop(player: QPlayer) {
    }
}

