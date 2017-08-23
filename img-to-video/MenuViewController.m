//
//  MenuViewController.m
//  img-to-video
//
//  Created by Tops on 11/9/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.
//

#import "MenuViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "GM_FSHighlightAnimationAdditions.h"
#define LABEL_ONE_TEXT @"Left To Right"

@interface MenuViewController ()

@end

@implementation MenuViewController

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
    
    [btnSignIn.titleLabel GM_setAnimationLTRWithText:btnSignIn.titleLabel.text andWithDuration:2.0f andWithRepeatCount:0];
    imgThumb.layer.cornerRadius = 25;
    imgThumb.layer.masksToBounds = YES;
    
    spinner.layer.cornerRadius = 4;
    spinner.layer.masksToBounds = YES;
    
    UIImage* logoImage = [UIImage imageNamed:@"logo.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // here i can set accessToken received on previous login
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    appDelegate.instagram.sessionDelegate = self;
    
    if ([appDelegate.instagram isSessionValid]) {
        [self loadInstagramData];
        btnSignOut.hidden = NO;
        imgSeparator.hidden = NO;
        imgThumb.hidden = NO;
        lblName.hidden = NO;
        lblPhotos.hidden = NO;
        btnSignIn.hidden = YES;
    } else {
        btnSignOut.hidden = YES;
        imgSeparator.hidden = YES;
        imgThumb.hidden = YES;
        lblName.hidden = YES;
        lblPhotos.hidden = YES;
        btnSignIn.hidden = NO;
    }
}

-(IBAction)login {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}

-(IBAction)doLogout {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.instagram logout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)CreateStoryPressed:(id)sender {
    ViewController *controller = [[ViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)loadInstagramData {
    [spinner startAnimating];
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self", @"method", nil];
    [appDelegate.instagram requestWithParams:params
                                    delegate:self];
    
    if ([appDelegate.instagram isSessionValid]) {
        btnSignOut.hidden = NO;
        imgSeparator.hidden = NO;
        imgThumb.hidden = NO;
        lblName.hidden = NO;
        lblPhotos.hidden = NO;
        btnSignIn.hidden = YES;
    } else {
        btnSignOut.hidden = YES;
        imgSeparator.hidden = YES;
        imgThumb.hidden = YES;
        lblName.hidden = YES;
        lblPhotos.hidden = YES;
        btnSignIn.hidden = NO;
    }
}

#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    [self loadInstagramData];
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout {
    NSLog(@"Instagram did logout");
    [btnSignIn.titleLabel GM_setAnimationLTRWithText:btnSignIn.titleLabel.text andWithDuration:2.0f andWithRepeatCount:0];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([appDelegate.instagram isSessionValid]) {
        btnSignOut.hidden = NO;
        imgSeparator.hidden = NO;
        imgThumb.hidden = NO;
        lblName.hidden = NO;
        lblPhotos.hidden = NO;
        btnSignIn.hidden = YES;
    } else {
        btnSignOut.hidden = YES;
        imgSeparator.hidden = YES;
        imgThumb.hidden = YES;
        lblName.hidden = YES;
        lblPhotos.hidden = YES;
        btnSignIn.hidden = NO;
    }
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}

#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result {
    NSLog(@"Instagram did load: %@", result);
//    self.data = (NSArray*)[result objectForKey:@"data"];
//    [self.tableView reloadData];
    lblName.text = [[result objectForKey:@"data"] objectForKey:@"username"];
    lblPhotos.text = [NSString stringWithFormat:@"%d photos",[[[[result objectForKey:@"data"] objectForKey:@"counts"] objectForKey:@"media"] intValue]];
    [imgThumb setImageWithURL:[NSURL URLWithString:[[result objectForKey:@"data"] objectForKey:@"profile_picture"]]];
    [spinner stopAnimating];
}


@end
