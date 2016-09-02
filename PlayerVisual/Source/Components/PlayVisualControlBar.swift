//
//  PlayVisualControlBar.swift
//  PlayerVisual
//
//

import UIKit
import SnapKit


// MARK: -

// MARK: Player control bar slider

public class PlayerVisualControlSlider: UISlider {
    public var thumbImage: UIImage? {
        set {
            self.setThumbImage(newValue, forState: .Normal)
        }
        
        get {
            return self.currentThumbImage
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.thumbImage = UIImage(named: "icon_badge_bot")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // track bounds
    public override func trackRectForBounds(trackBounds: CGRect) -> CGRect {
        let sliderBounds = super.trackRectForBounds(trackBounds)
        return CGRectMake(sliderBounds.origin.x, sliderBounds.origin.y, sliderBounds.width, 3)
    }
    
    // thumb bounds
    public override func thumbRectForBounds(bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let thumbBounds = super.thumbRectForBounds(bounds, trackRect: rect, value: value)
        let thumbHeight = (self.thumbImage?.size.width ?? 0)
        return CGRectMake(thumbBounds.origin.x, (bounds.size.height - thumbHeight) / 2, thumbHeight, thumbHeight)
    }
}


// MARK: -

// MARK: PlayerControlBar delegate

@objc
public protocol PlayerVisualControlBarDelegate: NSObjectProtocol {
    
    optional func controlBarDidSlideToValue(value: Double)
    
    optional func controlBarPlayBottonDidTapped()
    
    optional func controlBarFullScreenBottonDidTapped()
    
}


// MARK: -

// MARK: Player control bar

public class PlayerVisualControlBar: UIView {
    
    public convenience init() {
        self.init(frame: CGRectMake(0, 0, 100, 50))
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
    
    // MARK: - Public
    
    /// delegate of PlayerVisualControlBar, which will recive bar bottons touching events and bar slider events.
    public weak var delegate: PlayerVisualControlBarDelegate?
    /// Inset of bar content.
    public var itemMarginLeft: CGFloat = 8
    public var itemMarginRight: CGFloat = 8
    public var itemSpace: CGFloat = 5
    public var timeLabelSize: CGSize = CGSize(width: 36, height: 20)
    public var playBottonSize: CGSize = CGSize(width: 25, height: 25)
    public var fullScreenButtonSize: CGSize = CGSize(width: 20, height: 20)
    /// Items space.
    /// Duration of animation.(Set 0 to disable animation.)
    public var animationDuration: NSTimeInterval = 0.5
    /// The time that bar will be hidden after shown.
    public var autoHideDelayTime: NSTimeInterval = 4
    /// Indicate that if the bar is shown.
    public var barIsHide: Bool {
        get {
            return self.isBarHide
        }
    }
    
    // Play botton image for `Play` stat
    public var playButtonImageForPlay: UIImage?
    // Play botton image for `Stop/Pause` stat
    public var playButtonImageForStop: UIImage?
    
    // Slider thumb image
    public var sliderThumbImage: UIImage? {
        get {
            return self.slider.thumbImage
        }
        
        set {
            self.slider.thumbImage = newValue
        }
    }
    
    /// Full screen button image
    public var fullScreenImage: UIImage? {
        get {
            return self.fullScreenBtn.backgroundImageForState(.Normal)
        }
        
        set {
            self.fullScreenBtn.setBackgroundImage(newValue, forState: .Normal)
        }
    }
    
    /// Should hide Full screen button.
    public var hideFullScreenButton: Bool = false {
        didSet {
            if oldValue != self.hideFullScreenButton {
                if self.hideFullScreenButton {
                    self.fullScreenBtn.snp_remakeConstraints {
                        [unowned self] make in
                        make.right.equalTo(self.barLayer).offset(self.itemMarginRight * (-1))
                        make.centerY.equalTo(self.playBtn)
                        make.height.equalTo(self.fullScreenButtonSize.height)
                        make.width.equalTo(0)
                    }
                    
                } else {
                    self.fullScreenBtn.snp_makeConstraints {
                        [unowned self] make in
                        make.right.equalTo(self.barLayer).offset(self.itemMarginRight * (-1))
                        make.centerY.equalTo(self.playBtn)
                        make.height.equalTo(self.fullScreenButtonSize.height)
                        make.width.equalTo(self.fullScreenButtonSize.width)
                    }
                }
            }
        }
    }
    
    /// If set to `true`, the bar will always be hidden except a timer indicator.
    public var alwaysHideBar: Bool = false {
        didSet{
            if self.alwaysHideBar {
                self.lockBar = true
            }
        }
    }
    
    /// Lock the bar that all events on it will not be delivered.
    public var lockBar: Bool = true {
        didSet {
            if self.alwaysHideBar {
                self.lockBar = true
                self.hideBarWithTimer(0)
            }
        }
    }
    
    /**
     Show control bar. (It will not be effective if `lockBar` or `alwaysHideBar` is true)
     
     - parameter autoHide: If set to `true`, the control bar will be hidden after `autoHideDelayTime` seconds.
     */
    public func showControlBar(autoHide: Bool) {
        guard !self.isAnimating && !self.lockBar else {
            return
        }
    
        self.barShow(autoHide)
    }
    
    /**
     Hide control bar. It will update timer. (It will not be effective if `lockBar` or `alwaysHideBar` is true)
     
     - parameter time: If timer is 0, the control bar will be hidden immediately, otherwise the bar will be hidden after `time` seconds.
     */
    public func hideControlBar(afterTime time: NSTimeInterval) {
        guard !self.isAnimating && !self.lockBar else {
            return
        }
        
        self.hideBarWithTimer(time)
    }
    
    /**
     Set current stat to "Play".
     */
    public func setPlayBtnIconForPlay() {
        self.playBtn.setImage(playButtonImageForPlay, forState: .Normal)
        self.isPlayBottonPlay = true
    }
    
    /**
     Set current stat to "Stop".
     */
    public func setPlayBtnIconForStop() {
        self.playBtn.setImage(playButtonImageForStop, forState: .Normal)
        self.isPlayBottonPlay = false
    }
    
    /**
     Set control bar max time label value.
     
     - parameter time: Max time.
     */
    public func setMaxTime(time: Double) {
        self.barMaxTime = time
        self.slider.minimumValue = 0
        self.slider.maximumValue = Float(self.barMaxTime)
    }
    
    public func setMaxTimeLabel(time: Double) {
        self.maxTimeLabel.text = self.contertTimevalToString(self.barMaxTime)
    }
    
    /**
     Set current bar progress.
     
     - parameter currentTime: Current time.
     */
    public func setProgress(currentTime: Double) {
        self.progress.progress = Float(currentTime / self.barMaxTime)
        self.slider.value = Float(currentTime)
    }
    
    public func setProgressLabel(currentTime: Double) {
        self.currentTimeLabel.text = self.contertTimevalToString(currentTime)
    }
    
    /**
     Layout bar components.
     */
    public func layoutBarViews() {
        if self.barLayouted {
            return
        }
        self.maxTimeLabel.text = self.contertTimevalToString(0)
        self.maxTimeLabel.textColor =  UIColor(red: 0.8494, green: 0.8494, blue: 0.8494, alpha: 1.0)
        self.maxTimeLabel.textAlignment = .Center
        self.maxTimeLabel.font = UIFont(name: "Helvetica", size: 10)
        self.currentTimeLabel.text = self.maxTimeLabel.text
        self.currentTimeLabel.textColor = self.maxTimeLabel.textColor
        self.currentTimeLabel.textAlignment = self.maxTimeLabel.textAlignment
        self.currentTimeLabel.font = self.maxTimeLabel.font
        
        self.setPlayBtnIconForStop()
        
        self.playBtn.snp_makeConstraints {
            [unowned self] make in
            make.left.equalTo(self.barLayer).offset(self.itemMarginLeft)
            make.centerY.equalTo(self.barLayer)
            make.height.equalTo(self.playBottonSize.height)
            make.width.equalTo(self.playBottonSize.width)
        }
        
        self.fullScreenBtn.snp_makeConstraints {
            [unowned self] make in
            make.right.equalTo(self.barLayer).offset(self.itemMarginRight * (-1))
            make.centerY.equalTo(self.playBtn)
            make.height.equalTo(self.fullScreenButtonSize.height)
            make.width.equalTo(self.fullScreenButtonSize.width)
        }
        
        self.currentTimeLabel.snp_makeConstraints {
            [unowned self] make in
            make.left.equalTo(self.playBtn.snp_right).offset(self.itemSpace)
            make.centerY.equalTo(self.playBtn)
            make.height.equalTo(self.timeLabelSize.height)
            make.width.equalTo(self.timeLabelSize.width)
        }
        
        self.maxTimeLabel.snp_makeConstraints {
            [unowned self] make in
            make.right.equalTo(self.fullScreenBtn.snp_left).offset(self.itemSpace * (-1))
            make.centerY.equalTo(self.currentTimeLabel)
            make.height.equalTo(self.currentTimeLabel)
            make.width.equalTo(self.currentTimeLabel)
        }
        
        self.slider.snp_makeConstraints {
            [unowned self] make in
            make.left.equalTo(self.currentTimeLabel.snp_right).offset(self.itemSpace)
            make.right.equalTo(self.maxTimeLabel.snp_left).offset(self.itemSpace * (-1))
            make.centerY.equalTo(self.currentTimeLabel)
            make.height.equalTo(self.currentTimeLabel)
        }
        
        self.barLayouted = true
    }
    
    // MARK: - Private
    
    private let playBtn = UIButton(frame: CGRectZero)
    private let fullScreenBtn = UIButton(frame: CGRectZero)
    private let currentTimeLabel = UILabel(frame: CGRectZero)
    private let maxTimeLabel = UILabel(frame: CGRectZero)
    private let slider = PlayerVisualControlSlider()
    private let progress = UIProgressView(progressViewStyle: .Bar)
    private let barLayer = UIView(frame: CGRectZero)
    private var barTimer: NSTimer?
    private var barMaxTime: Double = 0
    private var sliderAcceptChange: Bool = false
    private var barLayouted: Bool = false
    private var isPlayBottonPlay = false
    private var isBarHide = false
    private var isAnimating = false
    
    private func contertTimevalToString(time: NSTimeInterval) -> String {
        let min = Int(time / 60)
        let sec = Int(time % 60)
        return "\(self.contertTimeString(min)):\(self.contertTimeString(sec))"
    }
    
    private func contertTimeString(time: Int) -> String {
        var timeStr = "\(time)"
        if time > 99 {
            timeStr = "99"
        } else {
            if time < 10 {
                timeStr = "0\(time)"
            }
        }
        
        return timeStr
    }
    
    private func prepareBar() {
        self.backgroundColor = UIColor.clearColor()
        
        // layer
        self.barLayer.frame = self.bounds
        self.barLayer.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.barLayer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.barLayer.alpha = 1
        self.barLayer.hidden = false
        
        let holderGesture = UITapGestureRecognizer(target: self, action: #selector(doNothing))
        self.barLayer.userInteractionEnabled = true
        self.barLayer.addGestureRecognizer(holderGesture)
        
        
        // progress
        self.progress.frame = CGRectMake(0, self.frame.height - self.progress.frame.height, self.frame.width, 0)
        self.progress.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        self.progress.progressTintColor = UIColor.redColor()
        self.progress.alpha = 0
        self.progress.hidden = true
        
        self.addSubview(self.barLayer)
        self.addSubview(self.progress)
        
        self.barLayer.addSubview(self.playBtn)
        self.barLayer.addSubview(self.fullScreenBtn)
        self.barLayer.addSubview(self.currentTimeLabel)
        self.barLayer.addSubview(self.maxTimeLabel)
        self.barLayer.addSubview(self.slider)
        
        self.playBtn.addTarget(self, action: #selector(playButtonTapped), forControlEvents: .TouchUpInside)
        self.fullScreenBtn.addTarget(self, action: #selector(fullScreenButtonTapped), forControlEvents: .TouchUpInside)
        
        self.slider.addTarget(self, action: #selector(acceptSliderValueChange), forControlEvents: UIControlEvents.TouchDown)
        self.slider.addTarget(self, action: #selector(rejectSliderValueChange), forControlEvents: UIControlEvents.TouchCancel)
        self.slider.addTarget(self, action: #selector(rejectSliderValueChange), forControlEvents: UIControlEvents.TouchUpInside)
        self.slider.addTarget(self, action: #selector(sliderValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: Disable slider for developing.
        self.slider.enabled = false
        self.layoutBarViews()
    }
    
    func doNothing() {}
    
    private func hideBarWithTimer(interval: NSTimeInterval) {
        self.removeHideTimer()
        
        if 0 == interval || self.isBarHide {
            self.barHide(nil)
            return
        }
        
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
    
    internal func barShow(shouldHide: Bool) {
        if 0 < self.animationDuration && self.isBarHide {
            self.isAnimating = true
            self.barLayer.hidden = false
            
            UIView.animateWithDuration(self.animationDuration, animations: {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.barLayer.alpha = 1
                strongSelf.progress.alpha = 0
                
            }, completion: {
                [weak self] finished in
                guard let strongSelf = self else {
                    return
                }
                
                if !finished {
                    strongSelf.progress.alpha = 1
                    strongSelf.barLayer.alpha = 0
                    strongSelf.barLayer.hidden = true
                    
                } else {
                    strongSelf.progress.hidden = true
                    strongSelf.isBarHide = false
                }
                
                strongSelf.isAnimating = false
                
                if finished && shouldHide {
                    strongSelf.hideControlBar(afterTime: strongSelf.autoHideDelayTime)
                }
            })
            
            return
        }
        
        self.barLayer.alpha = 1
        self.progress.alpha = 0
        self.barLayer.hidden = false
        self.progress.hidden = true
        self.isBarHide = false
        
        if shouldHide {
            self.hideControlBar(afterTime: self.autoHideDelayTime)
        }
    }
    
    internal func barHide(timer: NSTimer?) {
        self.removeHideTimer()
        
        if nil != timer && 0 < self.animationDuration {
            self.isAnimating = true
            self.progress.hidden = false
            
            UIView.animateWithDuration(self.animationDuration, animations: {
                [weak self] in
                self?.barLayer.alpha = 0
                self?.progress.alpha = 1
                
            }, completion: {
                [weak self] finished in
                if finished {
                self?.barLayer.hidden = true
                self?.isBarHide = true
                        
                } else {
                    self?.barLayer.alpha = 1
                    self?.progress.alpha = 0
                    self?.progress.hidden = true
                }
                
                self?.isAnimating = false
            })
            
            return
        }
        
        self.progress.alpha = 1
        self.barLayer.alpha = 0
        self.progress.hidden = false
        self.barLayer.hidden = true
        self.isBarHide = true
    }
    
    internal func playButtonTapped() {
        if self.isAnimating {
            return
        }
        
        self.hideControlBar(afterTime: self.autoHideDelayTime)
        self.delegate?.controlBarPlayBottonDidTapped?()
    }
    
    internal func fullScreenButtonTapped() {
        if self.isAnimating {
            return
        }
        
        self.hideControlBar(afterTime: self.autoHideDelayTime)
        self.delegate?.controlBarFullScreenBottonDidTapped?()
    }
    
    internal func acceptSliderValueChange() {
        self.sliderAcceptChange = true
        self.showControlBar(false)
    }
    
    internal func rejectSliderValueChange() {
        self.sliderAcceptChange = false
        self.hideControlBar(afterTime: self.autoHideDelayTime)
    }
    
    internal func sliderValueChanged() {
        if self.isAnimating || !self.sliderAcceptChange {
            return
        }
        
        self.delegate?.controlBarDidSlideToValue?(Double(self.slider.value))
    }
}
