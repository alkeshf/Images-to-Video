//
//  AppDelegate.h
//  img-to-video
//
//  Created by Carmen Ferrara on 10/4/12.
//  Copyright (c) 2012 Carmen Ferrara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"
@class MenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UINavigationController *navigationController;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MenuViewController *viewController;

@property (strong, nonatomic) Instagram *instagram;
@property (strong, nonatomic) NSMutableArray *chosenImages;
@property(nonatomic, readwrite)BOOL isInstagram;
+(AppDelegate*)sharedInstance;

@end
