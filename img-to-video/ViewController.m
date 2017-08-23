//
//  ViewController.m
//  img-to-video
//
//  Created by Carmen Ferrara on 10/4/12.
//  Copyright (c) 2012 Carmen Ferrara. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import "VideoViewController.h"
#import "InstaGramViewController.h"
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIView *v in [scrollView subviews]) {
        [v removeFromSuperview];
    }
    [AppDelegate sharedInstance].chosenImages = [[NSMutableArray alloc]init];
//    durationArray = [[NSMutableArray alloc]initWithObjects:@"4",@"5",@"1",@"2",@"1",@"2",nil];
    controller = [[MPMusicPlayerController alloc]init];
    buttonArray = [[NSMutableArray alloc] init];
   UIImage *image = [UIImage imageNamed:@"nextbutton.png"];
    UIButton* btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage.frame=CGRectMake(0, 0, 67, 35);
    [btnImage setImage:image forState:UIControlStateNormal];
    [btnImage setShowsTouchWhenHighlighted:YES];
    [btnImage addTarget:self action:@selector(createVideo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnImage];
    
    UIImage *image1 = [UIImage imageNamed:@"backbutton.png"];
    UIButton* btnImage1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnImage1.frame=CGRectMake(0, 0, 67, 35);
    [btnImage1 setBackgroundImage:image1 forState:UIControlStateNormal];
    [btnImage1 setShowsTouchWhenHighlighted:YES];
    [btnImage1 addTarget:self action:@selector(MenuPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnImage1];
}

-(void)viewWillAppear:(BOOL)animated {
    if ([AppDelegate sharedInstance].isInstagram) {
        [self setImages];
    }
}

-(IBAction)AddPhotosClicked:(id)sender {
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc]
                   initWithTitle:@"Add Photo"
                   delegate:self
                   cancelButtonTitle:nil
                   destructiveButtonTitle:@"Cancel"
                   otherButtonTitles:@"Gallery",@"Camera", @"Instagram",nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (actionSheet.tag == 1) {
		if (buttonIndex == 0){
			
		}
		else if (buttonIndex == 1){
			[self launchController];
		}
		else if (buttonIndex == 2){
			[self openCamera];
		}else if (buttonIndex == 3) {
            [self openInstagram];
        }
	}
}

-(void)openInstagram {
    InstaGramViewController *controller1 = [[InstaGramViewController alloc]init];
    [self presentViewController:controller1 animated:YES completion:nil];
}

- (void)openCamera {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
	imagePicker.delegate = self;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//	[self presentModalViewController:imagePicker animated:YES];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)launchController
{
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] init];
    elcPicker.maximumImagesCount = 100;
	elcPicker.imagePickerDelegate = self;
    [self presentViewController:elcPicker animated:YES completion:nil];
}

-(IBAction)MenuPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)Next:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Provide Duration" message:@"Please enter duration for each image between 1 to 10 seconds" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",@"Cancel",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    txtDuration = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    //[albumName setBackgroundColor:[ApplicationData sharedInstance].color];
    txtDuration = [alert textFieldAtIndex:0];
    [txtDuration setBorderStyle:UITextBorderStyleRoundedRect];
    [txtDuration setKeyboardType:UIKeyboardTypeNumberPad];
    [txtDuration becomeFirstResponder];
    txtDuration.delegate = self;
    alert.tag = 1;
    [alert addSubview:txtDuration];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            if ([txtDuration.text intValue] > 0 && [txtDuration.text intValue] < 11) {
                [self createVideo:nil];
            }else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Please enter valid duration  between 1 to 10 seconds" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
                [alert show];
            }
        }
    }
}

- (IBAction)createVideo:(id)sender {
    if ([AppDelegate sharedInstance].chosenImages.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select images first" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    CGSize size = CGSizeMake(400, 200);
    UIImage *img = [[UIImage alloc]init];
    img = [self imageWithImage:[UIImage imageNamed:@"title-img.png"] scaledToSize:size];
    
    [[AppDelegate sharedInstance].chosenImages addObject:img];
    NSError *error = nil;
    
    
    // set up file manager, and file videoOutputPath, remove "test_output.mp4" if it exists...
    //NSString *videoOutputPath = @"/Users/someuser/Desktop/test_output.mp4";
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
    //NSLog(@"-->videoOutputPath= %@", videoOutputPath);
    // get rid of existing mp4 if exists...
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
    double numberOfSecondsPerFrame = 1;//[txtDuration.text intValue];
    double frameDuration = fps * numberOfSecondsPerFrame;
    //for(VideoFrame * frm in imageArray)
    NSLog(@"**************************************************");
    for(UIImage * img in imageArray)
    {
        int ind = [imageArray indexOfObject:img];
//        double numberOfSecondsPerFrame = [[durationArray objectAtIndex:ind] intValue];
//        double frameDuration = fps * numberOfSecondsPerFrame;
        //UIImage * img = frm._imageFrame;
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
    VideoViewController *controller1 = [[VideoViewController alloc]init];
    controller1.videoPath = videoPath;
    controller1.duration = 1;//[txtDuration.text intValue];
    [self.navigationController pushViewController:controller1 animated:YES];
    
}
////////////////////////
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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage;
	selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	CGSize size = selectedImage.size;
	CGFloat ratio = 0;
	if((selectedImage.size.height > 480) || (selectedImage.size.width > 320)){
		if (size.width > size.height) {
			ratio = 320.0 / size.width;
		}
		else {
			ratio = 480.0 / size.height;
		}
		CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
		
		UIGraphicsBeginImageContext(rect.size);
		[selectedImage drawInRect:rect];
		selectedImage = UIGraphicsGetImageFromCurrentImageContext();
	}
    CGSize size1 = CGSizeMake(400, 200);
    UIImage *img = [[UIImage alloc]init];
    img = [self imageWithImage:selectedImage scaledToSize:size1];
//    UIImageView *imageview = [[UIImageView alloc] initWithImage:img];
//    [imageview setContentMode:UIViewContentModeScaleAspectFit];
//    CGRect workingFrame;// = scrollView.frame.;
//    NSLog(@"width:%f",scrollView.contentSize.width);
//    workingFrame.origin.x = scrollView.contentSize.width + imageview.frame.size.width;
//    imageview.frame = CGRectMake(scrollView.contentSize.width, imageview.frame.origin.y, imageview.frame.size.width, imageview.frame.size.height);
//    [scrollView setPagingEnabled:YES];
//	[scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
//    [scrollView addSubview:imageview];
    [[AppDelegate sharedInstance].chosenImages addObject:img];
    [self setImages];
    
    //	userImage = [selectedImage retain];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
//	CGRect workingFrame;
//    if ([scrollView.subviews count] > 0) {
//        workingFrame = CGRectMake(scrollView.contentSize.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
//        workingFrame.origin.x = scrollView.contentSize.width;
//    }else {
//        workingFrame = scrollView.frame;
//        workingFrame.origin.x = 0;
//    }
	
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
	
	for (NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        [images addObject:image];
//		UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
//		[imageview setContentMode:UIViewContentModeScaleAspectFit];
//		imageview.frame = workingFrame;
//		[scrollView addSubview:imageview];
//		workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
	}
    NSMutableArray *imgList = [[NSMutableArray alloc]init];
    CGSize size = CGSizeMake(400, 200);
    for (int i = 0; i < [images count]; i++) {
        UIImage *img = [[UIImage alloc]init];
//        img = [self image:[images objectAtIndex:i] scaledToSize:size];
        img = [self imageWithImage:[images objectAtIndex:i] scaledToSize:size];
        [imgList addObject:img];
        [[AppDelegate sharedInstance].chosenImages addObject:img];
    }
//    self.chosenImages = [imgList mutableCopy];
	if ([[AppDelegate sharedInstance].chosenImages count] > 0) {
        btnCreate.hidden = NO;
    }
//	[scrollView setPagingEnabled:YES];
//	[scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
    
    [self setImages];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)setImages {
	int x = 5;
	int y = 5;
	float width = 100;
	float height = 100;
	float margin = 5;
    int imgPerPage;
    if (([UIScreen mainScreen].bounds.size.height == 568.0)) {
        imgPerPage = 12;
    }else {
        imgPerPage = 9;
    }
    
	int numberOfPages = [[AppDelegate sharedInstance].chosenImages count]/imgPerPage;
	if([[AppDelegate sharedInstance].chosenImages count] % imgPerPage > 0) {
		++numberOfPages;
	}
	[pageControl setNumberOfPages:numberOfPages];
	
	int count = 0;
	int tempPage = 0;
	
	for	(int i = 0; i < [[AppDelegate sharedInstance].chosenImages count]; ++i) {
		UIButton *btn;
		if([buttonArray count] > i ) {
			btn = [buttonArray objectAtIndex:i];
            
            x+=(width + margin);
			++count;
			
			if(tempPage != count/imgPerPage) {
				tempPage = count/imgPerPage;
				x = margin + tempPage * scrollView.frame.size.width;
				y = margin;
			} else if (count % 3 == 0) {
				x = margin + tempPage * scrollView.frame.size.width;
				y += (height + margin);
			}
		} else {
			btn = [UIButton buttonWithType:UIButtonTypeCustom];
			[scrollView addSubview:btn];
			[buttonArray addObject:btn];
			
			[btn setContentMode:UIViewContentModeScaleAspectFill];
			btn.frame = CGRectMake(x, y, width, height);
			[btn addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
            [btn setBackgroundColor:[UIColor redColor]];
			btn.tag = (NSInteger)count;
            
			x+=(width + margin);
			++count;
			
			if(tempPage != count/imgPerPage) {
				tempPage = count/imgPerPage;
				x = margin + tempPage * scrollView.frame.size.width;
				y = margin;
			} else if (count % 3 == 0) {
				x = margin + tempPage * scrollView.frame.size.width;
				y += (height + margin);
			}
		}
	}
	[self setPhotoList];
	
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberOfPages, scrollView.frame.size.width);
    NSLog(@"width:%f",scrollView.contentSize.width);
}

-(IBAction)selectPhoto:(id)sender {
    NSLog(@"tag:%d",[sender tag]);
}
#pragma mark --
#pragma mark setPhotoList

- (void)setPhotoList {
	NSArray *photoList = [AppDelegate sharedInstance].chosenImages;
    for (int i = 0; i < [photoList count]; i++) {
        UIButton *button = [buttonArray objectAtIndex:i];
        UIImage *img = [self imageWithImage:[photoList objectAtIndex:i] scaledToSize:CGSizeMake(100, 100)];
        [button setBackgroundImage:img forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrView {
	int tempPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    [pageControl setCurrentPage:tempPage];
}

@end
