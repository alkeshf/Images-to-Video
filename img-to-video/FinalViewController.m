
//  FinalViewController.m
//  img-to-video

//  Created by Tops on 12/5/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.


#import "FinalViewController.h"

@interface FinalViewController ()

@end

@implementation FinalViewController
@synthesize videoUrl;
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
    self.title = @"Share";
    
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
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)PlayPressed:(id)sender {
    
    [btnPlay setImage:nil forState:UIControlStateNormal];
    //[avPlayerLayer setBackgroundColor:[[UIColor redColor]CGColor]];
    [player1 seekToTime:kCMTimeZero];
    
    [player1 play];
}

-(IBAction)MenuPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)FBPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/videos"];
    
    NSURL *videoPathURL = videoUrl;//[[NSURL alloc]initFileURLWithPath:videoPath isDirectory:NO];
    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
    
    NSString *status = @"One step closer.";
    NSDictionary *params = @{@"title":status, @"description":status};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:params];
    
    [request addMultipartData:videoData
                     withName:@"source"
                         type:@"video/quicktime"
                     filename:[videoPathURL absoluteString]];
}

-(IBAction)InstagramPressed:(id)sender {
    NSURL *instagramURL1 = [NSURL URLWithString:@"instagram://"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL1])
    {
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
        {
            [[UIApplication sharedApplication] openURL:instagramURL];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Instagram not installed in this device!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(IBAction)EmailPressed:(id)sender {
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:@"My Story"];
    //    NSArray *toRecipients = [NSArray arrayWithObjects:@"toto@toto.com", nil];
//    [mailer setToRecipients:toRecipients];

    
    if(videoUrl != nil)
    {
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        [mailer addAttachmentData:videoData mimeType:@"video/mp4" fileName:@"video01"];
    }
    NSString *emailBody = @"This video is created using InstaStory app for iOS,its awesome and helps you create a video out of your memorable pictures and makes a story for life,Have you created your story??";
    [mailer setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailer animated:YES completion:nil];
}

-(IBAction)SavePressed:(id)sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - Email Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    switch (result){
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
//            [[AVAudio sharedAudio] playMusicKey: @"phenominal"];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    //Remove the mail view
//    [self dismissModalViewControllerAnimated:YES];
}

@end
