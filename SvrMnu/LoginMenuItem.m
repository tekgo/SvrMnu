//
//  LoginMenuItem.m
//
//  Created by Patrick Winchell on 8/26/13.
//  Copyright (c) 2013 Patrick Winchell. All rights reserved.
//

#import "LoginMenuItem.h"

@implementation LoginMenuItem

#define kloginBool @"startAtLogin"

-(id) init {
    
    if((self = [super init]))
	{
        
        NSMutableDictionary *defaults =[[NSMutableDictionary alloc] init];
        
        [defaults setValue:[NSNumber numberWithBool:FALSE] forKey:kloginBool];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
        
        [[NSUserDefaults standardUserDefaults] setBool:[self isLoginItem] forKey:kloginBool];
        
        [self setCheckMark];
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];     NSString *appName = [[NSFileManager defaultManager] displayNameAtPath: bundlePath];
        appName = [[NSRunningApplication currentApplication] localizedName];
        self.title = [NSString stringWithFormat:@"Start %@ at login",appName];
        self.action = @selector(toggleLoginItems);
        self.target=self;
    }
    return self;
}

-(void)setCheckMark {
    if([[NSUserDefaults standardUserDefaults] boolForKey:kloginBool])
        [self setState:NSOnState];
    else
        [self setState:NSOffState];
}

-(void)toggleLoginItems{
    bool should = ![[NSUserDefaults standardUserDefaults] boolForKey:kloginBool];
    [[NSUserDefaults standardUserDefaults] setBool:should forKey:kloginBool];
    if(should) {
        [self addAppAsLoginItem];
    }
    else {
        [self deleteAppFromLoginItem];
    }
    [self setCheckMark];
    
}

-(void) addAppAsLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i=0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                                 objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		//[loginItemsArray release];
	}
}

-(BOOL)isLoginItem {
    BOOL res=false;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i=0 ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                                 objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					res=true;
				}
			}
		}
		//[loginItemsArray release];
	}
    return res;
}

@end
