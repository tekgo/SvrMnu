//
//  SvrBowWFHMenu.m
//  ServerBowser
//
//  Created by Codemonkey on 10/15/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrBowWFHMenu.h"

@implementation SvrBowWFHMenu
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

-(void)refresh {
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
                               [self makeMenus];
                               [self updateDelegate];
                               //NSLog(responseString);
                                    }];
}

-(void)makeMenus {
    [[self submenu] removeAllItems];
    numServers=0;
    numPlayers=0;
    if(gameInfo!=nil)
    {
        numServers = [(NSString*)[gameInfo valueForKey:@"activegames"] intValue];
        if(numServers==0)
            [self setTitle:@"WFH-No active games"];
        if(numServers==1)
            [self setTitle:@"WFH-1 active game"];
        if(numServers>1)
            [self setTitle:[NSString stringWithFormat:@"WFH-%d active games",numServers]];
        if(numServers>0)
        {
            for(NSDictionary *serverInfo in (NSArray*)[gameInfo valueForKey:@"servers"] )
            {
                numPlayers+=[(NSString*)[serverInfo valueForKey:@"players"] intValue];
                NSString *title;
                if ([(NSString*)[serverInfo valueForKey:@"players"] intValue]==1) {
                    title=[NSString stringWithFormat:@"1 player on %@-%@", [serverInfo valueForKey:@"map"], [serverInfo valueForKey:@"ip"]];
                }
                else
                    title=[NSString stringWithFormat:@"%@ players on %@-%@",[serverInfo valueForKey:@"players"], [serverInfo valueForKey:@"map"], [serverInfo valueForKey:@"ip"]];
                [[self submenu] addItemWithTitle:title action:nil keyEquivalent:@""];
            }
        }
    }
    else
    {
        [self setTitle:@"WFH-Unable to connect"];
    }
    if(gameInfo!=nil)
        value = numPlayers;
    else
        value = -1;
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

@end
