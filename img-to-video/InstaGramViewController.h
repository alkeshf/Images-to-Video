//
//  InstaGramViewController.h
//  img-to-video
//
//  Created by Tops on 11/22/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"
@interface InstaGramViewController : UIViewController <IGRequestDelegate,IGSessionDelegate>{
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIScrollView *scrollView;
    NSMutableArray* data;
    NSMutableArray *buttonArray;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIImageView *imgvw;
    IBOutlet UIActivityIndicatorView *spinner;
}

@end
