//
//  SvrBowSourceServer.m
//  ServerBowser
//
//  Created by Patrick Winchell on 10/14/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrBowSourceServer.h"

@implementation SvrBowSourceServer

@synthesize serverInfo;

-(id) init {
    
    if((self = [super init]))
	{
        
    
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        NSError *error = nil;
	
        [udpSocket bindToPort:0 error:&error];
        [udpSocket beginReceiving:&error];

        NSString *host = @"rbtf2.game.nfoservers.com";
        int port = 27015;
        //NSString *msg = @"ÿÿÿÿTSource Engine Query";
        //NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        
        const char bytes[] = "\xFF\xFF\xFF\xFF\x54\x53\x6F\x75\x72\x63\x65\x20\x45\x6E\x67\x69\x6E\x65\x20\x51\x75\x65\x72\x79\x00";
        size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
        
        NSData *data = [NSData dataWithBytes:bytes length:length];
        
        [udpSocket sendData:data toHost:host port:port withTimeout:15 tag:1];
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
