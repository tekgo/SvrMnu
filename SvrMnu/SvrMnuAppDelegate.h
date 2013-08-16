//
//  SvrMnuAppDelegate.h
//  SvrMnu
//
//  Created by Tekgo on 10/11/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SvrMnuWFHMenu.h"
#import "Blink1.h"
#import "Reachability.h"


@interface SvrMnuAppDelegate : NSObject <NSApplicationDelegate,SvrMnuMenuDelegate> {
    NSMenu *statusMenu;
    NSStatusItem * statusItem;
    SvrMnuWFHMenu *wfhMenu;
    NSTimer *refreshTimer;
    NSTimeInterval lastRefresh;
    NSMenuItem *refresher;
    NSMenuItem *refreshRate;
    
    bool screenAsleep;
    bool userDeactive;
    Blink1 *blink;
    Reachability *reach;
    NSWindowController *windowC;
    
    NSTimer *updateTimer;
    

}
-(void)setupMenu;
-(void)quit;
-(void)setTitle:(NSString*)title;

-(void)cancelRefresh;

@end
