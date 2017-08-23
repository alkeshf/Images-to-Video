//
//  FinalViewController.h
//  img-to-video
//
//  Created by Tops on 12/5/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface FinalViewController : UIViewController <MFMailComposeViewControllerDelegate>{
    IBOutlet UIButton *btnPlay;
    AVURLAsset* audioAsset;
    
    AVPlayer *player1;
    AVAsset *vAsset;
    AVPlayerItem *avPlayerItem;
    AVPlayerLayer *avPlayerLayer;
}
@property(nonatomic, retain)NSURL *videoUrl;
@end
