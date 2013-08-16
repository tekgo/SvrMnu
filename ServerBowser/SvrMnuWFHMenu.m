//
//  SvrMnuWFHMenu.m
//  SvrMnu
//
//  Created by Codemonkey on 10/15/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrMnuWFHMenu.h"
#import "Reachability.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation SvrMnuWFHMenu
@synthesize delegate,value;
-(id) init {
    
    if((self = [super init]))
	{
        [self setTitle:@"Waiting For Horus"];
        [self setSubmenu:[NSMenu alloc]];
        launcher = [[NSMenuItem alloc] initWithTitle:@"Launch WFH" action:@selector(launchWFH) keyEquivalent:@""];
        [launcher setTarget:self];
        [self makeMenus];
        //[self refresh];

    }
    return self;
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 350, 22)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    //[input layout];
    //[alert layout];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}

-(void)refresh {
    
    
    //[self input:@"Enter the Address of the server you want to add" defaultValue:@"butts"];
    //return;
    
            [self setTitle:@"WFH-Refreshing..."];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.xxiivv.com/?key=wfh&cmd=read"]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               gameInfo=nil;
                               if(!error)
                               {
                               NSError *err;
                               NSMutableDictionary *tempDict =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                               

                               
                               if(!err) {
                                   gameInfo=tempDict;
                               
                                   
                               }
                               }
                               [self performSelectorInBackground:@selector(makeMenus) withObject:nil];

                               //NSLog(responseString);
                                    }];
}

-(void)makeMenus {
    [[self submenu] removeAllItems];
    numServers=0;
    numPlayers=0;
    NSString *titleString = @"WFH-Unable to connect";
    bool selfie=false;
    if(gameInfo!=nil)
    {
        //NSString *ip = @"";
        //if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!=0)
           NSString *ip = [PortMapper findPublicAddress];
        numServers = [(NSString*)[gameInfo valueForKey:@"activegames"] intValue];
        if(numServers==0)
            titleString = @"WFH-No active games";
        if(numServers==1)
            titleString = @"WFH-1 active game";
        if(numServers>1)
            titleString = [NSString stringWithFormat:@"WFH-%d active games",numServers];
        if(numServers>0)
        {
            for(NSDictionary *serverInfo in (NSArray*)[gameInfo valueForKey:@"servers"] )
            {
                numPlayers+=[(NSString*)[serverInfo valueForKey:@"players"] intValue];
                NSString *title;
                if([ip isEqualToString:[serverInfo valueForKey:@"ip"]])
                    selfie=true;
                if ([(NSString*)[serverInfo valueForKey:@"players"] intValue]==1) {
                    title=[NSString stringWithFormat:@"1 player on %@-%@", [serverInfo valueForKey:@"map"], [serverInfo valueForKey:@"ip"]];
                }
                else
                    title=[NSString stringWithFormat:@"%@ players on %@-%@",[serverInfo valueForKey:@"players"], [serverInfo valueForKey:@"map"], [serverInfo valueForKey:@"ip"]];
                [[self submenu] addItemWithTitle:title action:nil keyEquivalent:@""];
            }
        }
    }
    if(gameInfo!=nil) {
        
        value = numPlayers;
        if(selfie)
            value--;
    }
    else
        value = -1;
    [self setTitle:titleString];
    [self updateDelegate];
    [[launcher menu] removeItem:launcher];
    if([self doesAppExist:@"unity.Les Collégiennes.WFH"])
    [[self submenu] addItem:launcher];
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

-(void)launchWFH {
    //[[NSWorkspace sharedWorkspace] launchApplication:@"WaitingForHorus-osx"];
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"unity.Les Collégiennes.WFH" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:NULL];
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
