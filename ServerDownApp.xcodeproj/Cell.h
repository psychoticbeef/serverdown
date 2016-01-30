//
//  Cell.h
//  ServerDownApp
//
//  Created by Daniel on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Cell : UITableViewCell {
    IBOutlet UIActivityIndicatorView *activity;
    IBOutlet UILabel *serverName;
    IBOutlet UILabel *watching;
}

- (void)awakeFromNib;

@property (nonatomic, retain) UIActivityIndicatorView *activity;
@property (nonatomic, retain) UILabel *serverName;
@property (nonatomic, retain) UILabel *watching;

@end
