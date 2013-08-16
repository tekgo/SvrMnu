//
//  SvrMnuWFHMenu.h
//  SvrMnu
//
//  Created by Tekgo on 10/15/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PortMapper.h"

@protocol SvrMnuMenuDelegate;

@interface SvrMnuMenu : NSMenuItem
{
    NSMenuItem *launcher;
    NSMutableDictionary *gameInfo;
    NSString *appBundleID;
    int numServers;
    int numPlayers;
}

@property  (nonatomic, weak)  id<SvrMnuMenuDelegate> delegate;
@property int value;

-(void)refresh;
-(void)launch;
-(void)makeMenus;
-(void) updateDelegate;
-(BOOL)doesAppExist:(NSString*)bundleID;



@end

@protocol SvrMnuMenuDelegate <NSObject>
-(void)setTitle:(NSString*)title;
@end