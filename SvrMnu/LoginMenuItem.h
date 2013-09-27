//
//  LoginMenuItem.h
//
//  Created by Patrick Winchell on 8/26/13.
//  Copyright (c) 2013 Patrick Winchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LoginMenuItem : NSMenuItem {
    LSSharedFileListRef loginItemsList;
}

-(void)update;

@end
