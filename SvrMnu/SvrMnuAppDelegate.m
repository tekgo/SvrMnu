//
//  SvrMnuAppDelegate.m
//  SvrMnu
//
//  Created by Tekgo on 10/11/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrMnuAppDelegate.h"

@implementation SvrMnuAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self doDefaults];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusMenu = [[NSMenu alloc] initWithTitle:@"..."];
    [statusItem setMenu:statusMenu];
    [statusMenu setDelegate:(id <NSMenuDelegate> )self];
    [self setupMenu];
    lastRefresh=0;
    
    blink = [[Blink1 alloc] init];      // set up blink(1) library
    [blink enumerate];

    
    [self refresh];
    
    reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
    
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didWake)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didSleep)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didWake)
                                                               name: NSWorkspaceScreensDidWakeNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didScreenSleep)
                                                               name: NSWorkspaceScreensDidSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didUserActive)
                                                               name: NSWorkspaceSessionDidBecomeActiveNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(didUserDeactive)
                                                               name: NSWorkspaceSessionDidResignActiveNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(refresh)
                                                               name: kReachabilityChangedNotification object: NULL];
    

}

-(void)doDefaults{
    NSMutableDictionary *defaults =[[NSMutableDictionary alloc] init];
    
    [defaults setValue:[NSNumber numberWithInt:5] forKey:@"refreshRate"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"enableHorus"];
}

-(void)setupMenu {
    [statusItem setTitle:@"..."];
    [statusItem setHighlightMode:YES];
    [statusMenu removeAllItems];

    if(!wfhMenu) {
        wfhMenu=[[SvrMnuWFHMenu alloc] init];
        wfhMenu.delegate=self;
    }
    if(!refresher) {
        refresher =[[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(forceRefresh) keyEquivalent:@""];

    }
    if(!refreshRate){
        refreshRate=[[NSMenuItem alloc] initWithTitle:@"Refresh Rate" action:nil keyEquivalent:@""];
        [refreshRate setSubmenu:[[NSMenu alloc] initWithTitle:@""]];
        [[refreshRate submenu] addItemWithTitle:@"1m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refreshRate submenu] itemAtIndex:0] setTag:1];
        [[refreshRate submenu] addItemWithTitle:@"2m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refreshRate submenu] itemAtIndex:1] setTag:2];
        [[refreshRate submenu] addItemWithTitle:@"5m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refreshRate submenu] itemAtIndex:2] setTag:5];
        [[refreshRate submenu] addItemWithTitle:@"10m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refreshRate submenu] itemAtIndex:3] setTag:10];
        [self changeRefreshRate:nil];
        
    }
    [statusMenu addItem:wfhMenu];
    [statusMenu addItem:refresher];
    [statusMenu addItem:refreshRate];
    [statusMenu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
    
}

-(void)changeRefreshRate:(id)sender {
    if(sender!=nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[(NSMenuItem*)sender tag] forKey:@"refreshRate"];
    }
    long rate = [[NSUserDefaults standardUserDefaults] integerForKey:@"refreshRate"];
    for(NSMenuItem* thisMenu in [[refreshRate submenu] itemArray])
    {
        [thisMenu setState:NSOffState];
        if(thisMenu.tag==rate)
            [thisMenu setState:NSOnState];
    }
    if(sender!=nil)
    {
        [self addTimer];
    }
    
}

-(void)refresh {
    [[NSRunLoop mainRunLoop] performSelector:@selector(_refresh) target:self argument:nil order:0 modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

-(void)_refresh {
    [self cancelRefresh];
    
    
    lastRefresh = [NSDate timeIntervalSinceReferenceDate];
    [self addTimer];
    if(userDeactive || (screenAsleep && ![blink isHere]) )
        return;
    [wfhMenu refresh];
}


-(void)cancelRefresh {
    if(refreshTimer!=nil)
        [refreshTimer invalidate];
}

-(void)forceRefresh {
    screenAsleep=false;
    userDeactive=false;
    [self refresh];
}

- (void)menuWillOpen:(NSMenu *)menu {
    [self updateRefresher];
    
    updateTimer = [NSTimer timerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(updateRefresher)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    
}

- (void)menuDidClose:(NSMenu *)menu {
    [updateTimer invalidate];
}

-(void)addTimer {
    long rate = [[NSUserDefaults standardUserDefaults] integerForKey:@"refreshRate"];
    float timeSince = [NSDate timeIntervalSinceReferenceDate]-lastRefresh;
    if(timeSince>(rate*60))
        [self refresh];
    else {
        [refreshTimer invalidate];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:((60.0*rate)-floor(timeSince)) target:self selector: @selector(refresh) userInfo:nil repeats: NO];
        [[NSRunLoop mainRunLoop] addTimer:refreshTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)didWake {
    NSLog(@"Wake");
    screenAsleep=false;
    [self enableBlink];
    [self refresh];
}

-(void)didScreenSleep {
    NSLog(@"Screensleep");
    screenAsleep=true;
    //if(![blink isHere])
    //[self cancelRefresh];
}

-(void)didSleep {
    NSLog(@"Sleep");
    screenAsleep=true;
    [blink off];
    //if(![blink isHere])
    //[self cancelRefresh];
}

-(void)didUserActive {
    NSLog(@"UserActive");
    userDeactive=false;
    [self didWake];
}

-(void)didUserDeactive {
    NSLog(@"Userdeactive");
    userDeactive=true;
    [blink off];
    //[self cancelRefresh];
    
}

-(void)updateRefresher
{
    float timeSince = [NSDate timeIntervalSinceReferenceDate]-lastRefresh;
    long rate = [[NSUserDefaults standardUserDefaults] integerForKey:@"refreshRate"];
    int seconds = (60*rate)-floor(timeSince);
    [refresher setTitle:[NSString stringWithFormat:@"Refresh(next in %ds)",seconds]];
    //NSLog([NSString stringWithFormat:@"Refresh-%d",seconds]);
    [statusMenu update];
}

-(void)setTitle:(NSString*)title {
    [self enableBlink];
    if(title!=statusItem.title) {
        if(title!=nil)
            [statusItem setTitle:title];
        else
            [statusItem setTitle:@"..."];
    }
}

-(void)_setTitle:(NSString*)title {
    
}

-(void)enableBlink {
    if(wfhMenu.value>0) {
        if(wfhMenu.value>1)
            [blink setPulse:[NSColor colorWithCalibratedRed:1 green:0 blue:1 alpha:1]];
        else
            [blink setPulse:[NSColor colorWithCalibratedRed:1 green:1 blue:0 alpha:1]];
    }
    else
        [blink off];
    if(wfhMenu.value<0)
        [blink setColor:[NSColor redColor]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [blink off];
}

-(void)quit
{
    [NSApp terminate:nil];
}






@end
