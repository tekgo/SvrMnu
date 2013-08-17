//
//  SvrMnuWFHMenu.m
//  SvrMnu
//
//  Created by Tekgo on 10/15/12.
//  Copyright (c) 2012 Patrick Winchell. All rights reserved.
//

#import "SvrMnuWFHMenu.h"
#import "Reachability.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation SvrMnuWFHMenu
-(id) init {
    
    if((self = [super init]))
	{
        appBundleID = @"unity.Les Collégiennes.WFH";
        [self setTitle:@"Waiting For Horus"];
        [self setSubmenu:[NSMenu alloc]];
        launcher = [[NSMenuItem alloc] initWithTitle:@"Launch WFH" action:@selector(launch) keyEquivalent:@""];
        [launcher setTarget:self];
        [self makeMenus];

    }
    return self;
}


-(void)refresh {
    [super refresh];
    
    
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
        if([gameInfo valueForKey:@"message"] && [[gameInfo valueForKey:@"message"] isKindOfClass:[NSString class]]) {
            NSString* message = [NSString stringWithFormat:@"MOTD: %@",(NSString*)[gameInfo valueForKey:@"message"]];
            [[self submenu] addItemWithTitle:message action:nil keyEquivalent:@""];
        }
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
        
        self.value = numPlayers;
        if(selfie)
            self.value--;
    }
    else
        self.value = -1;
    [self setTitle:titleString];
    [self updateDelegate];
    [[launcher menu] removeItem:launcher];
    if([self doesAppExist:appBundleID])
    [[self submenu] addItem:launcher];
}


-(void)launch {
    [super launch];
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:appBundleID options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:NULL];
}

@end
