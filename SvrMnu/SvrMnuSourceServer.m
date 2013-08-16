//
//  SvrMnuSourceServer.m
//  SvrMnu
//
//  Created by Patrick Winchell on 10/14/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrMnuSourceServer.h"

@implementation SvrMnuSourceServer

@synthesize serverInfo;

-(id) init {
    
    if((self = [super init]))
	{
        
    

    }
    return self;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{

    

    [data getBytes:&serverInfo.version range:NSMakeRange(5, 2)];
    int index=6;
    readString(data,&index,serverInfo.hostname);
    readString(data,&index,serverInfo.map);
    readString(data,&index,serverInfo.game_directory);
    readString(data,&index,serverInfo.game_description);
    [data getBytes:&serverInfo.app_id range:NSMakeRange(index, sizeof(short))];
    index++;
    [data getBytes:&serverInfo.num_players range:NSMakeRange(index, 1)];
    index++;
    [data getBytes:&serverInfo.max_players range:NSMakeRange(index, 1)];
    index++;
    
}



- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {

}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {

}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here

}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here

}

@end
