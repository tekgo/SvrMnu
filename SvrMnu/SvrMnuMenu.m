//
//  SvrMnuWFHMenu.m
//  SvrMnu
//
//  Created by Tekgo on 10/15/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrMnuMenu.h"
#import "Reachability.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation SvrMnuMenu
@synthesize delegate,value;
-(id) init {
    
    if((self = [super init]))
	{
    }
    return self;
}

-(void)refresh {
}

-(void)makeMenus {
}

-(void) updateDelegate{
    if(delegate!=nil && [delegate respondsToSelector:@selector(setTitle:)])
    {
        if(gameInfo!=nil){
            [delegate setTitle:[NSString stringWithFormat:@"%d",numPlayers]];
        }
        else
            [delegate setTitle:nil];
    }
}

-(void)launch {

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
