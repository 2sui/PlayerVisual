//
//  PlayVisualComponent.swift
//  PlayerVisual
//

import UIKit
import YYImage


// MARK: - PlayerControlBar

public class PlayerVisualControlBar: UIView {
    
    public convenience init() {
        self.init(frame: CGRectZero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareBar()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepareBar()
    }
    
    deinit {
        if nil != self.barTimer {
            self.barTimer!.invalidate()
            self.barTimer = nil
        }
    }
    
    public var lockBar = true
    public var isBarHide = false
    
    public func setProgress(currentTime: Double, maxTime: Double) {
        self.progress.progress = Float(currentTime / maxTime)
    }
    
    public func showControlBar() {
        guard self.isBarHide && !self.isAnimating else {
            return
        }
        
        guard !self.lockBar else {
            return
        }
        
        self.barShow()
    }
    
    public func hideControlBar(afterTime time: NSTimeInterval) {
        guard !self.isBarHide && !self.isAnimating else {
            return
        }
        
        guard !self.lockBar else {
            return
        }
        
        self.addBarHideTimer(time)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.progress.frame = self.bounds
    }
    
    // MARK: private
    private let progress = UIProgressView(progressViewStyle: .Bar)
    private var barTimer: NSTimer?
    private var isAnimating = false
    
    private func prepareBar() {
        self.backgroundColor = UIColor(red: 0.6871, green: 0.6871, blue: 0.6871, alpha: 0.3)
        self.progress.frame = CGRectZero
        self.addSubview(self.progress)
    }
    
    func barShow() {
        self.isAnimating = true
        self.hidden = false
        
        UIView.animateWithDuration(0.5, animations: {
            [unowned self] in
            self.alpha = 1
            
        }, completion: {
            [unowned self] finished in
            
            if !finished {
                self.alpha = 0
                self.hidden = true
                
            } else {
                self.isBarHide = false
            }
            
            self.isAnimating = false
            
            if finished {
                self.hideControlBar(afterTime: 4)
            }
        })
    }
    
    func barHide() {
        self.isAnimating = true
        
        UIView.animateWithDuration(0.5, animations: {
            [unowned self] in
            self.alpha = 0
            
        }, completion: {
            [unowned self] finished in
            if finished {
                self.hidden = true
                self.isBarHide = true
                
            } else {
                self.alpha = 1
            }
            
            self.removeHideTimer()
            self.isAnimating = false
        })
    }
    
    private func addBarHideTimer(interval: NSTimeInterval) {
        self.removeHideTimer()
        
        self.barTimer = NSTimer(timeInterval: interval, target: self, selector: #selector(barHide), userInfo: self, repeats: false)
        
        if let timer = self.barTimer {
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    private func removeHideTimer() {
        if nil != self.barTimer {
            self.barTimer!.invalidate()
            self.barTimer = nil
        }
    }
    
}

// MARK: - PlayerVisualIndictaor

public class PlayerVisualViewDefault: NSObject, PlayerVisualViewDelegate {
    public var barProgressResolution: NSTimeInterval = 0.1
    
    public override init() {
        super.init()
        self.prepareIndictaorViews()
    }

    // MARK: private 
    
    private let playIcon = YYAnimatedImageView(frame: CGRectMake(0, 0, 100, 100))
    private let stopIcon = YYAnimatedImageView(frame: CGRectMake(0, 0, 100, 100))
    private let loadView = UILabel(frame: CGRectMake(0, 0, 100, 50))
    private let failView = UILabel(frame: CGRectMake(0, 0, 100, 50))
    private let indictaor = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    private let controlBar = PlayerVisualControlBar()
    private var indictaorPreferAnimating = false
    private var isReady = false {
        didSet {
            if self.isReady {
                self.controlBar.lockBar = false
                self.controlBar.hideControlBar(afterTime: 3)
            }
        }
    }
    private var isPlay = false {
        didSet {
            if oldValue != self.isPlay {
                if self.isPlay {
                    self.isPause = false
                    
                } else {
                    self.isPause = true
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
        if let path = NSBundle.mainBundle().pathForResource("play", ofType: "png") {
            let image = YYImage(contentsOfFile: path)
            playIcon.image = image
        }
        if let path = NSBundle.mainBundle().pathForResource("stop", ofType: "png") {
            let image = YYImage(contentsOfFile: path)
            stopIcon.image = image
        }
        
        playIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        stopIcon.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        indictaor.hidesWhenStopped = true
        indictaor.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        failView.text = "视频加载失败"
        failView.textColor = UIColor.whiteColor()
        failView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        loadView.text = "视频加载中..."
        loadView.textColor = UIColor.whiteColor()
        loadView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        controlBar.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleWidth]
    }
}

extension PlayerVisualViewDefault {
    
    public func playerVisualViewStatuInitWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.loadView.center = playerVisual.view.center
        return self.loadView
    }
    
    // ready to play
    public func playerVisualViewReadyToPlayWithPlaceHolder(playerVisual: PlayerVisual) -> UIView? {
        self.isReady = true
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
        
        if self.controlBar.isBarHide {
            self.controlBar.showControlBar()
        } else {
            self.controlBar.hideControlBar(afterTime: 4)
        }
        return !self.isPlay
    }
    
    public func playerVisualViewSlidedShouldSeekToTime(playerVisual: PlayerVisual) -> NSTimeInterval {
        return 0
    }
    
    // MARK: indictaor view
    
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
    
    
    // MARK: control bar
    
    public func playerVisualControlBarHeight(playerVisual: PlayerVisual) -> CGFloat {
        return 25
    }
    
    public func playerVisualControlBarView(playerVisual: PlayerVisual) -> UIView? {
        return controlBar
    }
    
    public func playerVisualControlBarProgressPreferChange(playerVisual: PlayerVisual, currentTime: NSTimeInterval, maximumDuration: NSTimeInterval) {
        if currentTime == 0 || currentTime == maximumDuration || currentTime - self.lastBarProgressUpdate >= self.barProgressResolution {
            self.lastBarProgressUpdate = currentTime
            controlBar.setProgress(currentTime, maxTime: maximumDuration)
        }
    }
}


