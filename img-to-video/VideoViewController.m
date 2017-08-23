//
//  VideoViewController.m
//  img-to-video
//
//  Created by Tops on 11/11/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.
//

#import "VideoViewController.h"
#import "AppDelegate.h"
#import "FinalViewController.h"
@interface VideoViewController ()

@end

@implementation VideoViewController
@synthesize videoPath,duration;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int secs = [[AppDelegate sharedInstance].chosenImages count] * duration;
//    int h = (secs/3600);
//    secs = secs-(h*3600);
    int m = (secs/60);
    secs = secs - (m*60);
    duration = secs;
    lblDuration.text = [NSString stringWithFormat:@"Story length: %.2d : %.2d",m,secs];
    
    firstImage = [[AppDelegate sharedInstance].chosenImages objectAtIndex:0];
    txtTitle.delegate = self;
    scrollView.contentSize = CGSizeMake(320, 500);
    trimControl = [[RETrimControl alloc] initWithFrame:CGRectMake(5, btnChoose.frame.origin.y + btnChoose.frame.size.height + 20, 260, 28)];
     // 200 seconds
    trimControl.delegate = self;
    [songView addSubview:trimControl];
    trimControl.hidden = YES;
    videoUrl = [NSURL fileURLWithPath:videoPath];
    NSLog(@"path:%@  URL:%@",videoPath,videoUrl);
    UIImage *image1 = [UIImage imageNamed:@"backbutton.png"];
    UIButton* btnImage1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage1.frame=CGRectMake(0, 0, 67, 35);
    [btnImage1 setBackgroundImage:image1 forState:UIControlStateNormal];
    [btnImage1 setShowsTouchWhenHighlighted:YES];
    [btnImage1 addTarget:self action:@selector(MenuPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnImage1];
    
    vAsset = [AVAsset assetWithURL:videoUrl];
    avPlayerItem =[[AVPlayerItem alloc]initWithAsset:vAsset];
    player1 = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:player1];
    [avPlayerLayer setFrame:btnPlay.frame];
    avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
    [self.view.layer addSublayer:avPlayerLayer];
    [self.view bringSubviewToFront:btnPlay];
    [self.view bringSubviewToFront:lblDuration];
    [self.view bringSubviewToFront:txtTitle];
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    UIImage *image = [UIImage imageNamed:@"donebutton.png"];
    UIButton* btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage.frame=CGRectMake(0, 0, 67, 35);
    [btnImage setImage:image forState:UIControlStateNormal];
    [btnImage setShowsTouchWhenHighlighted:YES];
    [btnImage addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnImage];
//    [player1 play];
// Do any additional setup after loading the view from its nib.

}

-(IBAction)SwitchToggled:(id)sender {
    if (titleToggle.isOn) {
        txtTitle.enabled = YES;
    }else {
        txtTitle.enabled = NO;
    }
}

-(IBAction)PlayPressed:(id)sender {
    
    [btnPlay setImage:nil forState:UIControlStateNormal];
    //[avPlayerLayer setBackgroundColor:[[UIColor redColor]CGColor]];
    [player1 seekToTime:kCMTimeZero];
    
    [player1 play];
}

-(IBAction)MenuPressed:(id)sender {
    [[AppDelegate sharedInstance].chosenImages removeLastObject];
    [[AppDelegate sharedInstance].chosenImages replaceObjectAtIndex:0 withObject:firstImage];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    isRecording = YES;
    lblRecord.text = @"recording..";
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [recordPauseButton setTitle:@"Stop" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        audioAsset = [AVAsset assetWithURL:recorder.url];
        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [stopButton setEnabled:YES];
}

- (IBAction)stopTapped:(id)sender {
    lblRecord.text = @"recorded";
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    audioAsset = [AVAsset assetWithURL:recorder.url];
}


-(void)MergeAudio {
    _hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"Loading...";
    
    [self performSelectorInBackground:@selector(DoProcess) withObject:nil];
}

-(void)DoProcess
{
    ////////////////////////////////////////////////////////////////////////////
    //////////////  OK now add an audio file to move file  /////////////////////
    AVMutableComposition* mixComposition = [AVMutableComposition composition];

    NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
    // audio input file...
    NSString *audio_inputFilePath = [bundleDirectory stringByAppendingPathComponent:@"30secs.mp3"];
    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];

    // this is the video file that was just written above, full path to file is in --> videoOutputPath
//    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:videoOutputPath];

    // create the final video output file as MOV file - may need to be MP4, but this works so far...
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:@"final_video.mp4"];
    NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];

    CMTime nextClipStartTime = kCMTimeZero;

    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];

    if (!audioAsset) {
        audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    }

    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];


    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"public.mpeg-4";
    _assetExport.outputURL = outputFileUrl;
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         dispatch_async(dispatch_get_main_queue(), ^{
//             if (maskImg) {
//                 [self mergeOverLay:outputFileUrl];
//             }else {
                 FinalViewController *controller1 = [[FinalViewController alloc]init];
                 controller1.videoUrl = outputFileUrl;
              
                 [self.navigationController pushViewController:controller1 animated:YES];
                 [self exportDidFinish1:_assetExport];
//             }
         });
     }
     ];
    
   NSLog(@"DONE.....outputFilePath--->%@", outputFilePath);
}

- (void)exportDidFinish1:(AVAssetExportSession*)session
{
    if(session.status == AVAssetExportSessionStatusCompleted){
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error){
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                if (error) {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                                                    [alert show];
                                                }else{
//                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//                                                    [alert show];
                                                }
                                                vAsset = [AVAsset assetWithURL:assetURL];
                                                avPlayerItem =[[AVPlayerItem alloc]initWithAsset:vAsset];
                                                player1 = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
                                                avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:player1];
                                                [avPlayerLayer setFrame:btnPlay.frame];
                                                avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
                                                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
                                                [self.view.layer addSublayer:avPlayerLayer];
                                                [self.view bringSubviewToFront:btnPlay];
                                                [self.view bringSubviewToFront:lblDuration];
                                            });
                                        }];
        }
    }
}

- (IBAction) showMediaFilesPressed : (id) sender
{
    picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    
    picker.delegate                    = self;
    picker.allowsPickingMultipleItems  = NO;
    picker.prompt                      = NSLocalizedString(@"AddSongsPrompt", @"Prompt to user to choose some songs to play");
//    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated:YES];
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)trimAudio
{
    float vocalStartMarker = trimControl.leftValue;
    float vocalEndMarker = trimControl.leftValue + (speedSlider.value * [[AppDelegate sharedInstance].chosenImages count]);
    
    NSURL *audioFileInput = songUrl;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryCachesDirectory = [paths objectAtIndex:0];
    libraryCachesDirectory = [libraryCachesDirectory stringByAppendingPathComponent:@"Caches"];
    
    NSString *strOutputFilePath = [NSString stringWithFormat:@"%@%@",libraryCachesDirectory,@"/abc.mp4"];
    NSURL *audioFileOutput = [NSURL fileURLWithPath:strOutputFilePath];
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             audioAsset = [AVAsset assetWithURL:exportSession.outputURL];
             [self MergeAudio];
             // It worked!
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // It failed...
         }
     }];
    
    return YES;
}

-(IBAction)smallPlayPressed:(id)sender {
    MPMusicPlayerController* appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [appMusicPlayer setQueueWithItemCollection:collection];
    
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {
        [appMusicPlayer stop];
        timer = nil;
        [timer invalidate];
        songSlider.value = 0;
        [btnSmallPlay setImage:[UIImage imageNamed:@"smallplaybutton.png"] forState:UIControlStateNormal];
    }else {
        [appMusicPlayer play];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update_Slider_Time) userInfo:nil repeats:YES];
        [btnSmallPlay setImage:[UIImage imageNamed:@"smallpausebutton.png"] forState:UIControlStateNormal];
    }
}
-(void)update_Slider_Time {
        songSlider.value = player.currentTime;
}

//// MPMediaPicker delegate

// Media picker delegate methods
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    // We need to dismiss the picker
    collection = mediaItemCollection;
    NSArray * SelectedSong = [mediaItemCollection items];
    if([SelectedSong count]>0){
        MPMediaItem * SongItem = [SelectedSong objectAtIndex:0];
        
        NSURL *SongURL = [SongItem valueForProperty: MPMediaItemPropertyAssetURL];
        NSData *data = [NSData dataWithContentsOfURL:SongURL];
        songUrl = SongURL;
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:songUrl error:nil];
        audioAsset = [AVAsset assetWithURL:SongURL];
        trimControl.length = player.duration;
        trimControl.hidden = NO;
        songSlider.maximumValue  = player.duration;
        btnSmallPlay.hidden = NO;
        isRecording = NO;
        lblSongTitle.text = [SongItem valueForProperty:MPMediaItemPropertyTitle];
        
        NSLog(@"Audio Loaded %f",player.duration);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(IBAction)Done:(id)sender {
    
    
    if (audioAsset) {
        if (isRecording) {
            [self MergeAudio];
        }else {
            [self trimAudio];
        }
    }else {
        if (maskImg) {
            [self mergeOverLay:videoUrl];
        }else {
            FinalViewController *controller1 = [[FinalViewController alloc]init];
            controller1.videoUrl = videoUrl;
            [self.navigationController pushViewController:controller1 animated:YES];
        }
    }
    
}

- (IBAction)createVideo:(id)sender {
    
    NSError *error = nil;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
   if ([fileMgr removeItemAtPath:videoOutputPath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    CGSize imageSize = CGSizeMake(400, 200);
    NSUInteger fps = 24;
    
    NSArray *imageArray;
    imageArray = [AppDelegate sharedInstance].chosenImages;//[[NSMutableArray alloc] initWithCapacity:imagePaths.count];
    NSLog(@"-->imageArray.count= %i", imageArray.count);
    
    //////////////     end setup    ///////////////////////////////////
    
    NSLog(@"Start building video from defined frames.");
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:videoOutputPath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:imageSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:imageSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    int frameCount = 0;
    double numberOfSecondsPerFrame = speedSlider.value;
    double frameDuration = fps * numberOfSecondsPerFrame;
    //for(VideoFrame * frm in imageArray)
    NSLog(@"**************************************************");
    for(UIImage * img in imageArray)
    {
        buffer = [self pixelBufferFromCGImage:[img CGImage]];
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                //print out status:
                NSLog(@"Processing video frame (%d,%d)",frameCount,[imageArray count]);
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    NSLog(@"**************************************************");
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    NSLog(@"Write Ended");
    videoPath = videoOutputPath;
    videoUrl = [NSURL fileURLWithPath:videoPath];
    vAsset = [AVAsset assetWithURL:videoUrl];
    avPlayerItem =[[AVPlayerItem alloc]initWithAsset:vAsset];
    player1 = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:player1];
    [avPlayerLayer setFrame:btnPlay.frame];
    avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
    [self.view.layer addSublayer:avPlayerLayer];
    [self.view bringSubviewToFront:btnPlay];
    [self.view bringSubviewToFront:lblDuration];
    
//    VideoViewController *controller1 = [[VideoViewController alloc]init];
//    controller1.videoPath = videoPath;
//    controller1.duration = [txtDuration.text intValue];
//    [self.navigationController pushViewController:controller1 animated:YES];
    
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image {
    
    
    CGSize size = CGSizeMake(400, 200);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}



- (UIImage *)currentDrawing
{
//    UIGraphicsBeginImageContextWithOptions
    UIGraphicsBeginImageContextWithOptions(viewTitle.bounds.size, NO, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [viewTitle.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    // User did not select anything
    // We need to dismiss the picker
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)MasksClicked:(id)sender {
    if ([sender tag] == 301) {
        maskImg = [UIImage imageNamed:@"Joymask.png"];
    }else if ([sender tag] == 302) {
        maskImg = [UIImage imageNamed:@"WaterDropmask.png"];
    }else if ([sender tag] == 303) {
        maskImg = [UIImage imageNamed:@"paint.png"];
    }else if ([sender tag] == 304) {
        maskImg = [UIImage imageNamed:@"heartmask.png"];
    }else if ([sender tag] == 305) {
        maskImg = [UIImage imageNamed:@"crossmask.png"];
    }else if ([sender tag] == 306) {
        maskImg = [UIImage imageNamed:@"Disneymask.png"];
    }
    [self mergeOverLay:videoUrl];
}

-(void)mergeOverLay:(NSURL *)Vidurl {
    AVAsset *videoAsset;
    videoAsset = [AVAsset assetWithURL:Vidurl];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            videoUrl = url;
            vAsset = [AVAsset assetWithURL:videoUrl];
            avPlayerItem =[[AVPlayerItem alloc]initWithAsset:vAsset];
            player1 = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
            avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:player1];
            [avPlayerLayer setFrame:btnPlay.frame];
            avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:avPlayerItem];
            [self.view.layer addSublayer:avPlayerLayer];
            [self.view bringSubviewToFront:btnPlay];
            [self.view bringSubviewToFront:lblDuration];
            [self.view bringSubviewToFront:txtTitle];
//            FinalViewController *controller1 = [[FinalViewController alloc]init];
//            controller1.videoUrl = url;
//            [self.navigationController pushViewController:controller1 animated:YES];
        });
    }];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 1 - set up the overlay
    CALayer *overlayLayer = [CALayer layer];
    UIImage *overlayImage = maskImg;
    
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    // 2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 3 - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}


#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [stopButton setEnabled:NO];
    //    [playButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) itemDidFinishPlaying {
    NSLog(@"stop");
    [btnPlay setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
}
#pragma mark RETrimControlDelegate

- (void)trimControl:(RETrimControl *)trimControl didChangeLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue
{
    NSLog(@"Left = %f, right = %f", leftValue, rightValue);
}

-(void)text {
    txtBig.text = @"";
    txtBig.hidden= NO;
    [self.view bringSubviewToFront:txtBig];
    txtBig.layer.cornerRadius = 8;
    txtBig.layer.masksToBounds = YES;
	[txtBig becomeFirstResponder];
    UIButton* btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage.frame=CGRectMake(0, 0, 67, 35);
    [btnImage setTitle:@"Done" forState:UIControlStateNormal];
    [btnImage setShowsTouchWhenHighlighted:YES];
    [btnImage addTarget:self action:@selector(DoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnImage];//[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(DoneButtonPressed:)];
    self.navigationItem.leftBarButtonItem = nil;
    [UIView beginAnimations:nil context:NULL]; {
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.5];
		if ([self view].bounds.size.height == 480) {
            txtBig.frame = CGRectMake(0.0, 64.0, 320.0, 200.0);
        }else {
            txtBig.frame = CGRectMake(0.0, 64.0, 320.0, 288.0);
        }
	} [UIView commitAnimations];
}

-(IBAction)SliderValueChanged:(id)sender {
    
//    duration = speedSlider.value;
    int secs = [[AppDelegate sharedInstance].chosenImages count] * speedSlider.value;
    int m = (secs/60);
    secs = secs - (m*60);
    duration = secs;
    lblDuration.text = [NSString stringWithFormat:@"Story length: %.2d : %.2d",m,secs];
    [self performSelector:@selector(createVideo:) withObject:nil afterDelay:0.1];
    
}

-(IBAction)SliderMoved:(id)sender {
    [player1 pause];
    [btnPlay setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
//    [self createVideo:nil];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [txtTitle resignFirstResponder];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(text) userInfo:nil repeats:NO];
}

-(IBAction)DoneButtonPressed:(id)sender {
    txtTitle.text = txtBig.text;
    [txtBig setHidden:YES];
    [txtBig resignFirstResponder];
    txtTitle.text = txtBig.text;
    UIImage *image1 = [UIImage imageNamed:@"backbutton.png"];
    UIButton* btnImage1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage1.frame=CGRectMake(0, 0, 67, 35);
    [btnImage1 setBackgroundImage:image1 forState:UIControlStateNormal];
    [btnImage1 setShowsTouchWhenHighlighted:YES];
    [btnImage1 addTarget:self action:@selector(MenuPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnImage1];
    UIImage *image = [UIImage imageNamed:@"donebutton.png"];
    UIButton* btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage.frame=CGRectMake(0, 0, 67, 35);
    [btnImage setImage:image forState:UIControlStateNormal];
    [btnImage setShowsTouchWhenHighlighted:YES];
    [btnImage addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnImage];
    
    
    if (titleToggle.isOn && txtTitle.text.length !=0) {
        lblTitle.text = txtTitle.text;
        UIImage *img = [self currentDrawing];
        img = [self imageWithImage:img scaledToSize:CGSizeMake(400, 200)];
        CGSize itemSize = CGSizeMake(400, 200);
        
        UIGraphicsBeginImageContext(itemSize);
        
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [firstImage drawInRect:imageRect];
        [img drawInRect:imageRect];
        
        UIImage *overlappedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[AppDelegate sharedInstance].chosenImages replaceObjectAtIndex:0 withObject:overlappedImage];
        //        [[AppDelegate sharedInstance].chosenImages insertObject:img atIndex:0];
        [self createVideo:nil];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(void)viewWillDisappear:(BOOL)animated {
    timer = nil;
    [timer invalidate];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"yes");
}

@end
