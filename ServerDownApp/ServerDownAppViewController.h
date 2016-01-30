//
//  ServerDownAppViewController.h
//  ServerDownApp
//
//  Created by Daniel on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerDownAppAppDelegate.h"

@interface ServerDownAppViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SDTokenReadyDelegate> {
    ServerDownAppAppDelegate *delegate;
    
    UITableView *tv;
    
    NSString *token;
    
    NSMutableArray *serverList;
    NSMutableArray *selectedServers;
    NSMutableArray *pending;
    
    bool loaded;
    
    NSOperationQueue *queue;
}

- (void)loadList;
- (void)loadServers;
- (void)showAlert:(NSString *)message;
- (void)mainThreadAnimatedTV:(NSIndexPath *)withObject;

@property (assign) bool loaded;

@end
