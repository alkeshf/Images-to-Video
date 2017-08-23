//
//  AppDelegate.m
//  img-to-video
//
//  Created by Carmen Ferrara on 10/4/12.
//  Copyright (c) 2012 Carmen Ferrara. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuViewController.h"

#define APP_ID @"fd725621c5e44198a5b8ad3f7a0ffa09"
static AppDelegate *applicationData = nil;
@implementation AppDelegate
@synthesize instagram = _instagram,chosenImages,isInstagram;

+ (AppDelegate*)sharedInstance {
    if (applicationData == nil) {
        applicationData = [[super allocWithZone:NULL] init];
		[applicationData initialize];
    }
    return applicationData;
}

- (void)initialize {
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.instagram = [[Instagram alloc] initWithClientId:APP_ID
                                                delegate:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"topbar1.png"] forBarMetrics:UIBarMetricsDefault];
    }else {
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"topbar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    navigationController.navigationBar.tintColor = [UIColor clearColor];
    navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.instagram handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.instagram handleOpenURL:url];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
