//
//  PlayerVisualViewDefault.swift
//  PlayerVisual
//

import UIKit


// MARK: -

// MARK: PlayerVisual extension
extension PlayerVisual: PlayerVisualControlBarDelegate {
    
    public func registDelegateForPlayVisualControlBar(bar: PlayerVisualControlBar) {
        bar.delegate = self
    }
    
    public func didSetToProgress(progress: Double) {
    }
    
    public func playBottonDidTapped() {
        guard .Failed != self.playbackState else {
            return
        }
        
        if .Playing == self.playbackState {
            self.pause()
            
        } else {
            self.playFromCurrentTime()
        }
    }
    
    public func fullScreenBottonDidTapped() {
    }
}


// MARK: -

// MARK: PlayerVisualViewDefault

public class PlayerVisualViewDefault: NSObject, PlayerVisualViewDelegate {
    public var barProgressResolution: NSTimeInterval = 1
    
    public override init() {
        super.init()
        self.prepareIndictaorViews()
    }
    
    // MARK: - public 
    
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
    
    
    // MARK: - private
    
    private let playIcon = UIImageView(frame: CGRectMake(0, 0, 100, 100))
    private let stopIcon = UIImageView(frame: CGRectMake(0, 0, 100, 100))
    private let loadView = UILabel(frame: CGRectMake(0, 0, 300, 50))
    private let failView = UILabel(frame: CGRectMake(0, 0, 320, 50))
    private let indictaor = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    private let controlBar = PlayerVisualControlBar(frame: CGRectMake(0, 0, 100, 50)) // the frame just used for layout
    private var indictaorPreferAnimating = false
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
                if self.isPlay {
                    self.isPause = false
                    self.controlBar.setStatPlay()
                    
                } else {
                    self.isPause = true
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
        self.playIcon.image = UIImage(named: "btn_play_bg_a")
        self.stopIcon.image = UIImage(named: "btn_pause_longmv_big_a")
        
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
    
    public func playerVisualViewStatuInitWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.loadView.center = playerVisual.view.center
        return self.loadView
    }
    
    // ready to play
    public func playerVisualViewReadyToPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.isReady = true
        // MARK: regist control bar delegate
        playerVisual.registDelegateForPlayVisualControlBar(self.controlBar)
        self.playIcon.center = playerVisual.view.center
        return self.playIcon
    }
    
    // play
    public func playerVisualViewPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        guard self.isReady else {
            return nil
        }
        
        self.isPlay = true
        return nil
    }
    
    // pause
    public func playerVisualViewPauseWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        guard self.isPlay else {
            return nil
        }
        
        self.isPlay = false
        self.stopIcon.center = playerVisual.view.center
        return self.stopIcon
    }
    
    // stop
    public func playerVisualViewStopWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.isPlay = false
        self.playIcon.center = playerVisual.view.center
        return self.playIcon
    }
    
    // error
    public func playerVisualViewFailWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.isReady = false
        self.isPlay = false
        self.failView.center = playerVisual.view.center
        return self.failView
    }
    
    public func playerVisualViewTappedShouldPlay(playerVisual: PlayerVisual) -> Bool {
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
    
    public func playerVisualViewSlidedShouldSeekToTime(playerVisual: PlayerVisual) -> NSTimeInterval {
        return 0
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
        
        if currentTime == 0 || currentTime == maximumDuration || currentTime - self.lastBarProgressUpdate >= self.barProgressResolution {
            self.lastBarProgressUpdate = currentTime
            self.controlBar.setProgress(currentTime)
        }
    }
}


