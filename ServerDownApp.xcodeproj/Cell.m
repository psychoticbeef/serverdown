//
//  Cell.m
//  ServerDownApp
//
//  Created by Daniel on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cell.h"


@implementation Cell

@synthesize activity, serverName, watching;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
        // Initialization code
	}
	
	return self;
}

- (void)awakeFromNib {
}

- (void)dealloc {
	[super dealloc];
}


@end
