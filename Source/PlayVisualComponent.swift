//
//  PlayVisualComponent.swift
//  PlayerVisual
//

import UIKit


public class PlayerVisualIndictaorView: UIView, PlayerVisualIndictaorViewDelegate {
 
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareIndictaorView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepareIndictaorView()
    }
    
    
    // MARK: private 
    
    private var isPlaying = false {
        didSet {
            if isPlaying {
                self.hidden = true
                
            } else {
                self.hidden = false
            }
            
            if self.indictaor.isAnimating() {
                self.indictaor.stopAnimating()
            }
        }
    }
    private var isBufferDelay = false {
        didSet {
            if self.isPlaying {
                if self.isBufferDelay {
                    self.addSubview(self.indictaor)
                    self.hidden = false
                    if !self.indictaor.isAnimating() {
                        self.indictaor.startAnimating()
                    }
                    
                } else {
                    self.hidden = true
                    self.indictaor.removeFromSuperview()
                    if self.indictaor.isAnimating() {
                        self.indictaor.stopAnimating()
                    }
                }
            }
        }
    }
    private let indictaor = UIActivityIndicatorView()
    
    private func prepareIndictaorView() {
        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        self.indictaor.frame = CGRectMake(0, 0, 40, 40)
        self.indictaor.center = self.center
        self.indictaor.hidesWhenStopped = true
        self.indictaor.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
    }
    
    
}

extension PlayerVisualIndictaorView {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
}


extension PlayerVisualIndictaorView {
    
    // first add to layer
    public func indictaorViewStatuInit() {
        NSLog("\(#function)")
    }
    
    // video asset ready to play
    public func indictaorViewReadyToPlay() {
        NSLog("\(#function)")
    }
    
    public func indictaorViewPlay() {
        NSLog("\(#function)")
        self.isPlaying = true
    }
    
    public func indictaorViewPause() {
        NSLog("\(#function)")
        self.isPlaying = false
    }
    
    public func indictaorViewStop() {
        NSLog("\(#function)")
        self.isPlaying = false
    }
    
    public func indictaorViewFail() {
        NSLog("\(#function)")
        self.isPlaying = false
    }
    
    public func indictaorViewBufferReady() {
        NSLog("\(#function)")
        self.isBufferDelay = false
    }
    
    public func indictaorViewBufferDelay() {
        NSLog("\(#function)")
        self.isBufferDelay = true
    }
    
    public func indictaorViewBufferError() {
        NSLog("\(#function)")
    }
}
