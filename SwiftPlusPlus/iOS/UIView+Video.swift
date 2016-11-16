//
//  UIView+Video.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 9/11/15.
//  Copyright © 2015 Drewag LLC. All rights reserved.
//

import UIKit
import MediaPlayer
import ObjectiveC

extension UIView {
    struct Keys {
        static var VideoController = "VideoController"
    }

    func playVideoWithURL(_ URL: Foundation.URL) -> VideoController {
        let videoController = VideoController(URL: URL, inView: self)
        objc_setAssociatedObject(
            self,
            &Keys.VideoController,
            videoController,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return videoController
    }
}

open class VideoController: NSObject {
    let moviePlayer: MPMoviePlayerController
    unowned let view: UIView

    fileprivate init(URL: Foundation.URL, inView: UIView) {
        self.view = inView
        self.moviePlayer = MPMoviePlayerController(contentURL: URL)

        super.init()

        self.moviePlayer.view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(UIViewAutoresizing.flexibleHeight)
    }

    func resume() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(moviePlayerPreparedToPlayDidChange(_:)),
            name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange,
            object: self.moviePlayer
        )
        if self.moviePlayer.isPreparedToPlay {
            self.moviePlayer.play()
        }
        else {
            self.moviePlayer.prepareToPlay()
        }
    }

    func pause() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange,
            object: self.moviePlayer
        )
        self.moviePlayer.pause()
    }

    func stop() {
        self.pause()
        self.moviePlayer.stop()
        self.moviePlayer.view.removeFromSuperview()
    }

    deinit {
        self.stop()
    }

    // MARK: Notifications

    func moviePlayerPreparedToPlayDidChange(_ notification: Notification) {
        if self.moviePlayer.isPreparedToPlay {
            if self.moviePlayer.view.superview == nil {
                self.moviePlayer.view.frame = self.view.bounds
                self.view.addSubview(self.moviePlayer.view)
            }
        }
    }
}
