//
//  SvrMnuAppDelegate.h
//  SvrMnu
//
//  Created by Codemonkey on 10/11/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SvrMnuWFHMenu.h"
#import "Blink1.h"
#import "Reachability.h"
//#import "SvrMnuMCServer.h"
#import "SvrMnuMCMenu.h"


@interface SvrMnuAppDelegate : NSObject <NSApplicationDelegate> {
   // NSWindow *window;
    NSMenu *statusMenu;
    NSStatusItem * statusItem;
    SvrMnuWFHMenu *wfhMenu;
    //SvrMnuMCMenu *wfhMenu;
    NSTimer *refreshTimer;
    NSTimeInterval lastRefresh;
    NSMenuItem *refresher;
    NSMenuItem *refreshRate;
    
    bool screenAsleep;
    bool userDeactive;
    Blink1 *blink;
    Reachability *reach;
    NSWindowController *windowC;
    //SvrMnuMCServer *test;

}
//@property (assign) IBOutlet NSWindow *window;
-(void)setupMenu;
-(void)quit;
-(void)setTitle:(NSString*)title;

-(void)cancelRefresh;

@end
