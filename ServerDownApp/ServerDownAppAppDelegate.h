//
//  ServerDownAppAppDelegate.h
//  ServerDownApp
//
//  Created by Daniel on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDownAppViewController;

@protocol SDTokenReadyDelegate;

@interface ServerDownAppAppDelegate : NSObject <UIApplicationDelegate> {
    NSString *token;
    id<SDTokenReadyDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ServerDownAppViewController *viewController;
@property (nonatomic, assign) NSString *token;
@property (nonatomic, assign) id<SDTokenReadyDelegate> delegate;

@end

@protocol SDTokenReadyDelegate
- (void) tokenReady;
@optional
@end