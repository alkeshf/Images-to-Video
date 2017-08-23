//
//  ViewController.h
//  img-to-video
//
//  Created by Carmen Ferrara on 10/4/12.
//  Copyright (c) 2012 Carmen Ferrara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ELCImagePickerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ViewController : UIViewController <ELCImagePickerControllerDelegate, UINavigationControllerDelegate, MPMediaPickerControllerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UIScrollViewDelegate,UITextFieldDelegate> {
    IBOutlet UIButton *btnCreate;
    MPMediaPickerController *picker;
    MPMusicPlayerController *controller;
    AVURLAsset* audioAsset;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    IBOutlet UIButton *recordPauseButton;
    IBOutlet UIButton *stopButton;
    NSMutableArray *durationArray;
    
    NSString *videoPath;
    IBOutlet UIScrollView *scrollView;
    NSMutableArray *buttonArray;
    IBOutlet UIPageControl *pageControl;
    UITextField *txtDuration;
}
//@property (nonatomic, copy) NSMutableArray *chosenImages;

- (IBAction)createVideo:(id)sender;

@end
