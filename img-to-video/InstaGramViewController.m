//
//  InstaGramViewController.m
//  img-to-video
//
//  Created by Tops on 11/22/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.
//

#import "InstaGramViewController.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
@interface InstaGramViewController ()

@end

@implementation InstaGramViewController

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
    
    spinner.layer.cornerRadius = 4;
    spinner.layer.masksToBounds = YES;
    [spinner startAnimating];
    data = [[NSMutableArray alloc]init];
    buttonArray = [[NSMutableArray alloc] init];
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbar.png"] forBarMetrics:UIBarMetricsDefault];
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.instagram.sessionDelegate = self;
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/media/recent", @"method", nil];
    [appDelegate.instagram requestWithParams:params
                                    delegate:self];
}

-(IBAction)CancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

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
    NSArray *arr = (NSArray*)[result objectForKey:@"data"];
    for (int i = 0; i < [arr count]; i++) {
        [data addObject:[[[[arr objectAtIndex:i] objectForKey:@"images"] objectForKey:@"low_resolution"] objectForKey:@"url"]];
    }
    [self setImages];
}

- (void)setImages {
	int x = 4;
	int y = 4;
	float width = 75;
	float height = 75;
	float margin = 4;
    int imgPerPage;
    if (([UIScreen mainScreen].bounds.size.height == 568.0)) {
        imgPerPage = 20;
    }else {
        imgPerPage = 16;
    }
    
	int numberOfPages = [data count]/imgPerPage;
	if([data count] % imgPerPage > 0) {
		++numberOfPages;
	}
	[pageControl setNumberOfPages:numberOfPages];
	
	int count = 0;
	int tempPage = 0;
	
	for	(int i = 0; i < [data count]; ++i) {
		UIImageView *btn;
		if([buttonArray count] > i ) {
			btn = [buttonArray objectAtIndex:i];
            
            x+=(width + margin);
			++count;
			
			if(tempPage != count/imgPerPage) {
				tempPage = count/imgPerPage;
				x = margin + tempPage * scrollView.frame.size.width;
				y = margin;
			} else if (count % 4 == 0) {
				x = margin + tempPage * scrollView.frame.size.width;
				y += (height + margin);
			}
		} else {
            btn = [[UIImageView alloc]init];
            btn.userInteractionEnabled = YES;
			[scrollView addSubview:btn];
			[buttonArray addObject:btn];
			
			[btn setContentMode:UIViewContentModeScaleAspectFill];
			btn.frame = CGRectMake(x, y, width, height);
            UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc]init];
            [tg addTarget:self action:@selector(selectPhoto:)];
//            [btn setBackgroundColor:[UIColor grayColor]];
            [btn addGestureRecognizer:tg];
			btn.tag = (NSInteger)count;
            
			x+=(width + margin);
			++count;
			
			if(tempPage != count/imgPerPage) {
				tempPage = count/imgPerPage;
				x = margin + tempPage * scrollView.frame.size.width;
				y = margin;
			} else if (count % 4 == 0) {
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
    NSLog(@"tag:%d",[(UIGestureRecognizer *)sender view].tag);
    UIView *vw = [(UIGestureRecognizer *)sender view];
    imgvw.image = [(UIImageView *)vw image];
    [AppDelegate sharedInstance].isInstagram = YES;
    CGSize size1 = CGSizeMake(400, 200);
    UIImage *img = [[UIImage alloc]init];
    img = [self imageWithImage:imgvw.image scaledToSize:size1];
    [[AppDelegate sharedInstance].chosenImages addObject:img];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark --
#pragma mark setPhotoList

- (void)setPhotoList {
    for (int i = 0; i < [data count]; i++) {
        UIImageView *button = [buttonArray objectAtIndex:i];
        NSString *str = [data objectAtIndex:i];
        [button setImageWithURL:[NSURL URLWithString:str]];
    }
    [spinner stopAnimating];
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

@end
