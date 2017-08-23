//
//  MenuViewController.h
//  img-to-video
//
//  Created by Tops on 11/9/13.
//  Copyright (c) 2013 Carmen Ferrara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"
#import "UIImageView+AFNetworking.h"
@interface MenuViewController : UIViewController<IGSessionDelegate,IGRequestDelegate> {
    IBOutlet UIImageView *imgThumb;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblPhotos;
    IBOutlet UIImageView *imgSeparator;
    IBOutlet UIButton *btnSignOut;
    IBOutlet UIButton *btnSignIn;
    IBOutlet UIActivityIndicatorView *spinner;
    
}

@end
