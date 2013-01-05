//
//  SvrBowWFHMenu.h
//  ServerBowser
//
//  Created by Codemonkey on 10/15/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PortMapper.h"
@interface SvrBowWFHMenu : NSMenuItem
{
    NSMenuItem *launcher;
    NSMutableDictionary *gameInfo;
    int numServers;
    int numPlayers;
}

@property id delegate;
@property int value;

-(void)refresh;
-(void)launchWFH;
-(void)makeMenus;
-(void) updateDelegate;

@end
