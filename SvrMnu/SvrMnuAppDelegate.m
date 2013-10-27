//
//  SvrMnuAppDelegate.m
//  SvrMnu
//
//  Created by Tekgo on 10/11/12.
//  Copyright (c) 2012 Patrick Winchell. All rights reserved.
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
    loginMenu = [[LoginMenuItem alloc] init];
    
    
    SvrMnuWFHMenu* wfhMenu =[[SvrMnuWFHMenu alloc] init];
    wfhMenu.delegate=self;
    SvrMnuANUMenu* anuMenu =[[SvrMnuANUMenu alloc] init];
    anuMenu.delegate=self;
    mnus = [NSMutableArray new];
    [mnus addObject:wfhMenu];
    [mnus addObject:anuMenu];

    long primaryIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"primaryMnu"];
    if(primaryIndex>=[mnus count] || primaryIndex<0)
        primaryIndex=0;
    primaryMnu = [mnus objectAtIndex:primaryIndex];

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
    [defaults setValue:[NSNumber numberWithInt:0] forKey:@"primaryMnu"];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"enableHorus"];
    
}

-(void)setupMenu {
    [statusItem setTitle:@"..."];
    [statusItem setHighlightMode:YES];
    [statusMenu removeAllItems];


    if(!refresher) {
        refresher =[[NSMenuItem alloc] initWithTitle:@"Refresh" action:@selector(forceRefresh) keyEquivalent:@""];
        [refresher setSubmenu:[[NSMenu alloc] initWithTitle:@""]];
        [[refresher submenu] addItemWithTitle:@"1m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refresher submenu] itemAtIndex:0] setTag:1];
        [[refresher submenu] addItemWithTitle:@"2m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refresher submenu] itemAtIndex:1] setTag:2];
        [[refresher submenu] addItemWithTitle:@"5m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refresher submenu] itemAtIndex:2] setTag:5];
        [[refresher submenu] addItemWithTitle:@"10m" action:@selector(changeRefreshRate:) keyEquivalent:@""];
        [[[refresher submenu] itemAtIndex:3] setTag:10];
        [self changeRefreshRate:nil];

    }
    /*if(!refreshRate){
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
        
    }*/
    
    if(primaryMnu!=NULL)
        [statusMenu addItem:primaryMnu];
    
    for (SvrMnuMenu *mnu in mnus) {
        if(mnu!=primaryMnu)
            [statusMenu addItem:mnu];
    }
    [statusMenu addItem:refresher];
    //[statusMenu addItem:refreshRate];
    [statusMenu addItem:loginMenu];
    [statusMenu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
    
}

-(void)changeRefreshRate:(id)sender {
    if(sender!=nil)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[(NSMenuItem*)sender tag] forKey:@"refreshRate"];
    }
    long rate = [[NSUserDefaults standardUserDefaults] integerForKey:@"refreshRate"];
    for(NSMenuItem* thisMenu in [[refresher submenu] itemArray])
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
    for (SvrMnuMenu *mnu in mnus) {
        [mnu refresh];
    }
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

-(void)setPrimaryMnu:(SvrMnuMenu *)mnu {
    primaryMnu = mnu;
    [self setupMenu];
    for (SvrMnuMenu *mnu in mnus) {
        [mnu makeMenus];
    }
    NSInteger index = [mnus indexOfObject:primaryMnu];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"primaryMnu"];
}

-(SvrMnuMenu*)getPrimaryMnu {
    return primaryMnu;
}

-(void)setTitle:(NSString*)title sender:(id)sender {
    if(sender==primaryMnu) {
        [self enableBlink];
        if(title!=statusItem.title) {
            if(title!=nil)
                [statusItem setTitle:title];
            else
                [statusItem setTitle:@"..."];
        }
    }
}

-(void)_setTitle:(NSString*)title {
    
}
-(void)enableBlink {
    [self performSelectorInBackground:@selector(_enableBlink) withObject:NULL];
}

-(void)_enableBlink {
    if(primaryMnu!=NULL) {
        if(primaryMnu.value>0) {
            if(primaryMnu.value>1)
                [blink setPulse:[NSColor colorWithCalibratedRed:1 green:0 blue:1 alpha:1]];
            else
                [blink setPulse:[NSColor colorWithCalibratedRed:1 green:1 blue:0 alpha:1]];
        }
        else
            [blink off];
        if(primaryMnu.value<0)
            [blink off];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [blink off];
}

-(void)quit
{
    [NSApp terminate:nil];
}

-(BOOL)doesAppExist:(NSString*)bundleID {
    BOOL res = false;
    CFURLRef appURL = NULL;
    OSStatus result = LSFindApplicationForInfo (
                                                kLSUnknownCreator,         //creator codes are dead, so we don't care about it
                                                (__bridge CFStringRef)bundleID, //you can use the bundle ID here
                                                NULL,                      //or the name of the app here (CFSTR("Safari.app"))
                                                NULL,                      //this is used if you want an FSRef rather than a CFURLRef
                                                &appURL
                                                );
    switch(result)
    {
        case noErr:
            res=true;
            break;
        case kLSApplicationNotFoundErr:
            res=false;
            break;
        default:
            res=false;
            break;
    }
    
    //the CFURLRef returned from the function is retained as per the docs so we must release it
    if(appURL)
        CFRelease(appURL);
    
    return res;
}





@end
