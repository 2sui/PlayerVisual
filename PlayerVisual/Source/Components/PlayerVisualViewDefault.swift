//
//  PlayerVisualViewDefault.swift
//  PlayerVisual
//

import UIKit


// MARK: -

// MARK: - PlayerVisualDefaultDelegate

@objc
public protocol PlayerVisualDefaultDelegate: PlayerVisualControlBarDelegate {
    
    optional func videoViewSizeChange(size: CGSize)
    
}


// MARK: -

// MARK: PlayerVisualDefault

public class PlayerVisualViewDefault: NSObject, PlayerVisualDelegate, PlayerVisualControlBarDelegate {
    
    public override init() {
        super.init()
        self.prepareIndictaorViews()
    }
    
    // MARK: - Public
    
    public weak var delegate: PlayerVisualDefaultDelegate? {
        didSet {
            self.controlBar.delegate = self
        }
    }
    
    public var barProgressResolution: NSTimeInterval = 1
    public var alwaysHideBar: Bool {
        get {
            return self.controlBar.alwaysHideBar
        }
        
        set {
            self.controlBar.alwaysHideBar = newValue
        }
    }
    
    public var hideFullScreenBotton: Bool {
        get {
            return self.controlBar.hideFullScreenButton
        }
        
        set {
            self.controlBar.hideFullScreenButton = newValue
        }
    }
        
    public let playIcon = UIImageView(frame: CGRectMake(0, 0, 100, 100))
    public let stopIcon = UIImageView(frame: CGRectMake(0, 0, 100, 100))
    public let loadView = UILabel(frame: CGRectMake(0, 0, 300, 50))
    public let failView = UILabel(frame: CGRectMake(0, 0, 320, 50))
    public let indictaor = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    
    // MARK: - Private
    private let controlBar = PlayerVisualControlBar(frame: CGRectMake(0, 0, 100, 50)) // the frame is just used for layout
    
    private var isReady = false {
        didSet {
            if self.isReady {
                self.controlBar.lockBar = false
                self.controlBar.showControlBar(true)
            }
        }
    }
    private var isPlay = false {
        didSet {
            if oldValue != self.isPlay {
                self.isPause = false
                
                if self.isPlay {
                    self.controlBar.setStatPlay()
                    
                } else {
                    self.controlBar.setStatStop()
                }
            }
        }
    }
    private var isPause = true {
        didSet {
            if oldValue != self.isPause {
                if self.isPlay {
                    if self.isPause {
                        self.indictaor.startAnimating()
                        
                    } else {
                        self.indictaor.stopAnimating()
                    }
                    
                } else {
                    self.indictaor.stopAnimating()
                }
            }
        }
    }
    
    private var lastBarProgressUpdate: NSTimeInterval = 0
    
    private func prepareIndictaorViews() {
        self.playIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        self.stopIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.indictaor.hidesWhenStopped = true
        self.indictaor.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.failView.text = "Oooops, the video is not availble for now."
        self.failView.textAlignment = .Center
        self.failView.textColor = UIColor.whiteColor()
        self.failView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleWidth]
        self.loadView.text = "视频加载中..."
        self.loadView.textAlignment = .Center
        self.loadView.textColor = UIColor.whiteColor()
        self.loadView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.controlBar.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleWidth]
    }
}


// MARK: -

// MARK: PlayerVisualViewDefault extension

extension PlayerVisualViewDefault {
    
    public func playerVisualStatuInitWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.loadView.center = playerVisual.view.center
        self.loadView.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        return self.loadView
    }
    
    // ready to play
    public func playerVisualReadyToPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.isReady = true
        
        self.playIcon.center = playerVisual.view.center
        self.playIcon.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        return self.playIcon
    }
    
    // play
    public func playerVisualPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        guard self.isReady else {
            return nil
        }
        
        self.isPlay = true
        return nil
    }
    
    // pause
    public func playerVisualPauseWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        guard self.isPlay else {
            return nil
        }
        
        self.isPlay = false
        self.stopIcon.center = playerVisual.view.center
        self.stopIcon.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        return self.stopIcon
    }
    
    // stop
    public func playerVisualStopWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.isPlay = false
        self.playIcon.center = playerVisual.view.center
        self.playIcon.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        return self.playIcon
    }
    
    // error
    public func playerVisualFailWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.isReady = false
        self.isPlay = false
        self.failView.center = playerVisual.view.center
        self.failView.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        return self.failView
    }
    
    // tap
    public func playerVisualTappedShouldPlay(playerVisual: PlayerVisual) -> Bool {
        guard self.isReady else {
            return false
        }
        
        if self.controlBar.barIsHide && !self.controlBar.alwaysHideBar {
            self.controlBar.showControlBar(true)
            // if video is playing, just show the bar
            if self.isPlay {
                return self.isPlay
            }
            
            return !self.isPlay
        }
        
        self.controlBar.hideControlBar(afterTime: self.controlBar.autoHideDelayTime)
        return !self.isPlay
    }
    
    // slide
    public func playerVisualSlidedSeekTimeWillSetWithInterval(playerVisual: PlayerVisual) -> Int64 {
        if !self.controlBar.barIsHide {
            self.controlBar.showControlBar(true)
        }
        return 1
    }
    
    // size change
    public func playerVisualVideoSizeChange(playerVisual: PlayerVisual, size: CGSize) {
        self.delegate?.videoViewSizeChange?(size)
    }
    
    // MARK: - indictaor view
    
    public func playerVisualIndictaorViewReady(playerVisual: PlayerVisual) -> UIView? {
        guard self.isPlay else {
            return nil
        }
        
        self.isPause = false
        return nil
    }
    
    public func playerVisualIndictaorViewError(playerVisual: PlayerVisual) -> UIView? {
        self.isPause = true
        return nil
    }
    
    public func playerVisualIndictaorViewDelay(playerVisual: PlayerVisual) -> UIView? {
        guard self.isPlay else {
            return nil
        }
        
        self.isPause = true
        self.indictaor.center = playerVisual.view.center
        self.indictaor.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin]
        return self.indictaor
    }
    
    
    // MARK: - control bar
    
    public func playerVisualControlBarHeight(playerVisual: PlayerVisual) -> CGFloat {
        return 40
    }
    
    public func playerVisualControlBarView(playerVisual: PlayerVisual) -> UIView? {
        return controlBar
    }
    
    public func playerVisualControlBarProgressPreferChange(playerVisual: PlayerVisual, currentTime: NSTimeInterval, maximumDuration: NSTimeInterval) {
        if 0 == currentTime {
            self.controlBar.setMaxTime(maximumDuration)
        }
        
        let diffTime = self.lastBarProgressUpdate < currentTime ? currentTime - self.lastBarProgressUpdate : self.lastBarProgressUpdate - currentTime
        
        if currentTime == 0 || currentTime == maximumDuration || diffTime >= self.barProgressResolution {
            self.lastBarProgressUpdate = currentTime
            self.controlBar.setProgress(currentTime)
        }
    }
    
    // MARK: - bar delegate
    public func controlBarDidSlideToValue(value: Double) {
        guard self.isReady else {
            return
        }
        self.delegate?.controlBarDidSlideToValue(value)
    }
    
    public func controlBarPlayBottonDidTapped() {
        guard self.isReady else {
            return
        }
        self.delegate?.controlBarPlayBottonDidTapped()
    }
    
    public func controlBarFullScreenBottonDidTapped() {
        self.delegate?.controlBarFullScreenBottonDidTapped()
    }
    
    
    public func controlBarPlayBottonImageForPlay() -> UIImage? {
        return self.delegate?.controlBarPlayBottonImageForPlay()
    }
    
    public func controlBarPlayBottonImageForStop() -> UIImage? {
        return self.delegate?.controlBarPlayBottonImageForStop()
    }
    
    public func controlBarSliderThumbImage() -> UIImage? {
        return self.delegate?.controlBarSliderThumbImage()
    }
    
    public func controlBarFullScreenBottonImage() -> UIImage? {
        return self.delegate?.controlBarFullScreenBottonImage()
    }
}


