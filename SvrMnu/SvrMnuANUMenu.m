//
//  SvrMnuANUMenu.m
//  SvrMnu
//
//  Created by Tekgo on 10/15/12.
//  Copyright (c) 2012 Patrick Winchell. All rights reserved.
//

#import "SvrMnuANUMenu.h"
#import "Reachability.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation SvrMnuANUMenu
-(id) init {
    
    if((self = [super init]))
	{
        appBundleID = @"unity.DefaultCompany.Anubis";
        [self setTitle:@"Hunting Anubis"];
        [self setSubmenu:[NSMenu alloc]];
        launcher = [[NSMenuItem alloc] initWithTitle:@"Launch Hunting Anubis" action:@selector(launch) keyEquivalent:@""];
        [launcher setTarget:self];
        [self makeMenus];

    }
    return self;
}


-(void)refresh {
    [super refresh];
    
    
            [self setTitle:@"Anubis-Refreshing..."];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.xxiivv.com/?key=anu&cmd=read"]]
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
                               [self performSelectorOnMainThread:@selector(makeMenus) withObject:Nil waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];

                                    }];
}

-(void)makeMenus {
    [[self submenu] removeAllItems];
    numServers=0;
    numPlayers=0;
    NSString *titleString = @"Anubis-Unable to connect";
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
            titleString = @"Anubis-No active games";
        if(numServers==1)
            titleString = @"Anubis-1 active game";
        if(numServers>1)
            titleString = [NSString stringWithFormat:@"Anubis-%d active games",numServers];
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
    [[self submenu] addItem:[self primarySetter]];
}


-(void)launch {
    [super launch];
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:appBundleID options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:NULL];
}

@end
