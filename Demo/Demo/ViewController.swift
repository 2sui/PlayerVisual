

import UIKit
import PlayerVisual

class ViewController: UIViewController, PlayerVisualDefaultDelegate {
    let videoView = UIView()
    let player = PlayerVisual()
    var playerComponent: PlayerVisualViewDefault!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        videoView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width)
        self.view.addSubview(videoView)
        
        playerComponent = PlayerVisualViewDefault()
        
        // set visual delegate before added to parent controller.
        player.visualDelegate = playerComponent
        
        playerComponent.delegate = self
//        playerComponent.alwaysHideBar = true
        playerComponent.hideFullScreenBotton = false
        playerComponent.playIcon.image = UIImage(named: "btn_play_bg_a")
        playerComponent.stopIcon.image = UIImage(named: "btn_pause_longmv_big_a")
        playerComponent.playButtonIconInControlBar = UIImage(named: "btn_pause_longmv_big_b")
        playerComponent.stopButtonIconInControlBar = UIImage(named: "btn_play_bg_b")
        playerComponent.sliderThumbInControlBar = UIImage(named: "icon_badge_bot")
        playerComponent.fullScreenButtonIconInControlBar = UIImage(named: "btn_full_screen")
        
        player.addToViewController(self, toView: videoView)
        
        self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        videoView.autoresizingMask = [ UIViewAutoresizing.FlexibleWidth]
        player.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        
        let url = NSURL(string: "https://static.videezy.com/system/resources/previews/000/004/685/original/Geo_Glass_-_Slideshow.mp4")!
        player.setUrl(url)
        
        player.autoPlay = false
        player.bufferSize = 6 // cache 6s data
        player.playbackLoops = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension ViewController {
    func controlBarDidSlideToValue(value: Double) {
        NSLog("\(#function) value: \(value)")
    }
    
    func controlBarPlayBottonDidTapped() {
        guard .Failed != player.playbackState else {
            return
        }
        
        if .Playing == player.playbackState {
            player.pause()
            return
        }
        
        player.playFromCurrentTime()
    }
    
    func controlBarFullScreenBottonDidTapped() {
        NSLog("\(#function)")
    }
    
    func videoViewSizeChange(size: CGSize) {
        videoView.frame.size.height = self.view.frame.width * (size.height / size.width)
    }
}

