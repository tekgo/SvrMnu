//
//  LoginMenuItem.m
//
//  Created by Patrick Winchell on 8/26/13.
//  Copyright (c) 2013 Patrick Winchell. All rights reserved.
//

#import "LoginMenuItem.h"

@implementation LoginMenuItem

#define kloginBoolName @"startAtLogin"

-(id) init {
    
    return [self initWithTitle:NULL action:NULL keyEquivalent:NULL];
}

-(id) initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode {
    
    if(aString==NULL)
        aString=@"";
    if(charCode==NULL)
        charCode=@"";
    aSelector = @selector(toggleLoginItems);
    
    
    if((self = [super initWithTitle:aString action:aSelector keyEquivalent:charCode]))
	{
        NSMutableDictionary *defaults =[[NSMutableDictionary alloc] init];
        
        [defaults setValue:[NSNumber numberWithBool:FALSE] forKey:kloginBoolName];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
        
        [[NSUserDefaults standardUserDefaults] setBool:[self isLoginItem] forKey:kloginBoolName];
        
        [self setCheckMark];
        if([aString isEqualToString:@""]) {
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];     NSString *appName = [[NSFileManager defaultManager] displayNameAtPath: bundlePath];
            appName = [[NSRunningApplication currentApplication] localizedName];
            self.title = [NSString stringWithFormat:@"Start %@ at login",appName];
        }
        self.target=self;
        
        loginItemsList = LSSharedFileListCreate(kCFAllocatorDefault,
                                                kLSSharedFileListSessionLoginItems, NULL);
        if(!loginItemsList)
        {
            @throw [NSException
                    exceptionWithName:@"LSSharedFileListCreateFailedException"
                    reason:@"Could not create shared file list" userInfo:nil];
            
        }
        
        LSSharedFileListAddObserver(loginItemsList,
                                    [[NSRunLoop mainRunLoop] getCFRunLoop],
                                    kCFRunLoopDefaultMode, LoginItemsChanged, (__bridge void *)(self));
    }
    
    return self;
}

-(void)update {
    [[NSUserDefaults standardUserDefaults] setBool:[self isLoginItem] forKey:kloginBoolName];
    [self setCheckMark];
}

-(void)setCheckMark {
    if([[NSUserDefaults standardUserDefaults] boolForKey:kloginBoolName])
        [self setState:NSOnState];
    else
        [self setState:NSOffState];
}

-(void)toggleLoginItems{
    bool should = ![[NSUserDefaults standardUserDefaults] boolForKey:kloginBoolName];
    [[NSUserDefaults standardUserDefaults] setBool:should forKey:kloginBoolName];
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
// http://www.cocoabuilder.com/archive/cocoa/220381-notification-on-login-items-change.html
static void LoginItemsChanged(LSSharedFileListRef list, void *context)
{
    [(__bridge id)context update];
}

- (void)dealloc
{
    if(loginItemsList)
    {
        LSSharedFileListRemoveObserver(loginItemsList,
                                       [[NSRunLoop mainRunLoop] getCFRunLoop],
                                       kCFRunLoopDefaultMode, LoginItemsChanged, (__bridge void *)(self));
        
        CFRelease(loginItemsList);
    }
}

@end
