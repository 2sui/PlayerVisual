

import UIKit
import PlayerVisual

class ViewController: UIViewController, PlayerVisualDefaultDelegate {
    let videoView = UIView()
    let player = PlayerVisual()
    var playerComponent: PlayerVisualViewDefault!
    var fullScreenController: UIViewController?
    var shouldFullScreen: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.videoView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width)
        self.view.addSubview(self.videoView)
        
        self.playerComponent = PlayerVisualViewDefault()
        
        // set visual delegate before added to parent controller.
        self.player.visualDelegate = playerComponent
        
        self.playerComponent.delegate = self
//        self.playerComponent.alwaysHideBar = true
        self.playerComponent.hideFullScreenBotton = false
        self.playerComponent.playIcon.image = UIImage(named: "btn_play_bg_a")
        self.playerComponent.stopIcon.image = UIImage(named: "btn_pause_longmv_big_a")
        self.playerComponent.playButtonIconInControlBar = UIImage(named: "btn_pause_longmv_big_b")
        self.playerComponent.stopButtonIconInControlBar = UIImage(named: "btn_play_bg_b")
        self.playerComponent.sliderThumbInControlBar = UIImage(named: "icon_badge_bot")
        self.playerComponent.fullScreenButtonIconInControlBar = UIImage(named: "btn_full_screen")
        
        
        self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        self.videoView.autoresizingMask = [ UIViewAutoresizing.FlexibleWidth]
        self.player.addToViewController(self, toView: self.videoView)
        
        let url = NSURL(string: "https://static.videezy.com/system/resources/previews/000/004/685/original/Geo_Glass_-_Slideshow.mp4")!
//        let url = NSURL(string: "http://mazwai.com/system/posts/videos/000/000/222/preview_mp4_3/ha_long_bay-penn_productions.mp4")!
        
        self.player.setUrl(url)
        self.player.autoPlay = false
        self.player.bufferSize = 6 // cache 6s data
        self.player.playbackLoops = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return shouldFullScreen
    }
}

extension ViewController {
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.shouldFullScreen = false
    }
    
    func controlBarDidSlideToValue(value: Double) {
        NSLog("\(#function) value: \(value)")
    }
    
    func controlBarPlayBottonDidTapped() {
        guard .Failed != self.player.playbackState else {
            return
        }
        
        if .Playing == self.player.playbackState {
            self.player.pause()
            return
        }
        
        self.player.playFromCurrentTime()
    }
    
    func controlBarFullScreenBottonDidTapped() {
        self.shouldFullScreen = true
        
        if nil != self.fullScreenController {
            self.player.addToViewController(self, toView: self.videoView)
            
            self.fullScreenController!.willMoveToParentViewController(nil)
            self.fullScreenController!.view.removeFromSuperview()
            self.fullScreenController!.removeFromParentViewController()
            self.fullScreenController = nil
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            return
        }
        
        self.fullScreenController = FullScreenController()
        self.addChildViewController(self.fullScreenController!)
        self.fullScreenController!.view.frame = self.view.bounds
        self.fullScreenController!.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        self.view.addSubview(self.fullScreenController!.view)
        self.fullScreenController!.didMoveToParentViewController(self)
        
        self.player.addToViewController(self.fullScreenController!, toView: self.fullScreenController!.view)
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
    }
    
    func videoViewSizeChange(size: CGSize) {
        self.videoView.frame.size.height = self.view.frame.width * (size.height / size.width)
    }
}

