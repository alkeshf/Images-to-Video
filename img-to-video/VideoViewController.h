//
//  VideoViewController.h
//  img-to-video
//
//  Created by Tops on 11/11/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "RETrimControl.h"

@interface VideoViewController : UIViewController <MPMediaPickerControllerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate, RETrimControlDelegate,UITextFieldDelegate,UITextViewDelegate>{
    NSURL *videoUrl;
    IBOutlet UIButton *btnPlay;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    MPMediaPickerController *picker;
    MPMusicPlayerController *controller;
    
    AVURLAsset* audioAsset;
    
    AVPlayer *player1;
    AVAsset *vAsset;
    AVPlayerItem *avPlayerItem;
    AVPlayerLayer *avPlayerLayer;
    
    IBOutlet UIButton *recordPauseButton;
    IBOutlet UIButton *stopButton;
    IBOutlet UIButton *btnChoose;
    MBProgressHUD *_hud;
    NSURL *songUrl;
    RETrimControl *trimControl;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIScrollView *scrollBorders;
    IBOutlet UILabel *lblSongTitle;
    IBOutlet UISlider *songSlider;
    IBOutlet UIButton *btnAddSong;
    IBOutlet UIButton *btnRecord;
    IBOutlet UISwitch *titleToggle;
    IBOutlet UITextField *txtTitle;
    
    IBOutlet UIView *viewTitle;
    IBOutlet UIView *songView;
    IBOutlet UILabel *lblTitle;
    UIImage *firstImage;
    
    IBOutlet UILabel *lblRecord;
    BOOL isRecording;
    IBOutlet UILabel *lblDuration;
    IBOutlet UIButton *btnSmallPlay;
    MPMediaItemCollection *collection;
    NSTimer *timer;
    IBOutlet UITextView *txtBig;
    IBOutlet UISlider *speedSlider;
    
    UIImage *maskImg;
}
@property (nonatomic, readwrite)float duration;
@property (nonatomic, retain)NSString *videoPath;


@end
