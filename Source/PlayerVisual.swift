//
//  PlayerVisual.swift
//  PlayerVisual
//
//  Created by zm_iOS on 16/8/12.
//  Copyright © 2016年 zm_iOS. All rights reserved.
//

import UIKit

@objc
public protocol PlayerVisualIndictaorViewDelegate: NSObjectProtocol {
    
    func startAnimating()
    
    func stopAnimating()
    
    func isAnimating() -> Bool
}

extension UIActivityIndicatorView: PlayerVisualIndictaorViewDelegate {
}

@objc
public protocol PlayerVisualHolderViewDelegate: NSObjectProtocol {
    optional func holderViewStatuInit()
    
    optional func holderViewStatuReady()
    
    optional func holderViewStatuPlaying()
    
    optional func holderViewStatuePause()
    
    optional func holderViewStatueStop()
    
    optional func holderViewStatueFail()
}

extension UIView: PlayerVisualHolderViewDelegate {
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
    public var holderView: PlayerVisualHolderViewDelegate? {
        didSet {
            if !(holderView is UIView) {
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
            (self.indictaorView! as! UIActivityIndicatorView).center = toView!.center
            (self.holderView! as! UIView).center = toView!.center
            self.view.addSubview((self.indictaorView! as! UIActivityIndicatorView))
            
        } else {
            (self.indictaorView as? UIActivityIndicatorView)?.removeFromSuperview()
        }
    }
    
}

extension PlayerVisual {
    
    private func prepareComponent() {
        self.prepareIndictaorComponent()
        self.prepareHolderViewComponent()
    }
    
    private func prepareIndictaorComponent() {
        if nil == self.indictaorView {
            self.indictaorView = UIActivityIndicatorView()
            (self.indictaorView! as! UIActivityIndicatorView).frame.size = CGSizeMake(40, 40)
            (self.indictaorView! as! UIActivityIndicatorView).hidesWhenStopped = true
            (self.indictaorView! as! UIActivityIndicatorView).autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleRightMargin]
        }
    }
    
    private func prepareHolderViewComponent() {
        if nil == holderView {
            self.holderView = UIView()
            (self.holderView! as! UIView).frame = self.view.bounds
            (self.holderView! as! UIView).alpha = 0.5
            (self.holderView! as! UIView).backgroundColor = UIColor.blackColor()
            (self.holderView! as! UIView).autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleRightMargin]
        }
    }
}

extension PlayerVisual {

    public func playerReady(player: Player) {
        
        if self.autoPlay {
            player.playFromBeginning()
        } else {
            self.holderView?.holderViewStatuReady?()
        }
    }
    
    public func playerPlaybackStateDidChange(player: Player) {
        NSLog("\(#function) \(player.playbackState)")
        
        switch player.playbackState {
            
        case .Some(.Failed):
            if let indictaor = self.indictaorView {
                if indictaor.isAnimating() {
                    indictaor.stopAnimating()
                }
            }
            
            self.holderView?.holderViewStatueFail?()
            
        case .Some(.Stopped):
            if let indictaor = self.indictaorView {
                if indictaor.isAnimating() {
                    indictaor.stopAnimating()
                }
            }
            
            self.holderView?.holderViewStatueStop?()
            
        case .Some(.Paused):
            if let indictaor = self.indictaorView {
                if indictaor.isAnimating() {
                    indictaor.stopAnimating()
                }
            }
            
            self.holderView?.holderViewStatuePause?()
            
        case .Some(.Playing):
            
            if let indictaor = self.indictaorView {
                if indictaor.isAnimating() {
                    indictaor.stopAnimating()
                }
            }
            
            self.holderView?.holderViewStatuInit?()
            
        default:
            break
        }
    }
    
    public func playerBufferingStateDidChange(player: Player) {
        NSLog("\(#function) \(player.bufferingState)")
        
        if player.playbackState == .Playing {
            
            switch player.bufferingState {
            case .None, .Some(.Unknown), .Some(.Delayed):
                if let indictaor = self.indictaorView {
                    if !indictaor.isAnimating() {
                        indictaor.startAnimating()
                    }
                }
                
            default:
                if let indictaor = self.indictaorView {
                    if indictaor.isAnimating() {
                        indictaor.stopAnimating()
                    }
                }
            }
        }
    }
    
    public func playerCurrentTimeDidChange(player: Player) {
        //        NSLog("\(#function) \(player.currentTime)")
    }
    
    public func playerPlaybackWillStartFromBeginning(player: Player) {
        NSLog("\(#function)")
    }
    
    public func playerPlaybackDidEnd(player: Player) {
        NSLog("\(#function) \(player.playbackState)")
    }
}
