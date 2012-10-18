//
//  SvrBowAppDelegate.h
//  ServerBowser
//
//  Created by Codemonkey on 10/11/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SvrBowWFHMenu.h"



@interface SvrBowAppDelegate : NSObject <NSApplicationDelegate> {
   // NSWindow *window;
    NSMenu *statusMenu;
    NSStatusItem * statusItem;
    SvrBowWFHMenu *wfhMenu;
    NSTimer *refreshTimer;
    NSTimeInterval lastRefresh;
    NSMenuItem *refresher;
    NSMenuItem *refreshRate;

}
//@property (assign) IBOutlet NSWindow *window;
-(void)setupMenu;
-(void)quit;
-(void)setTitle:(NSString*)title;

@end
