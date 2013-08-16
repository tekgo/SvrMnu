//
//  SvrMnuSourceServer.m
//  SvrMnu
//
//  Created by Patrick Winchell on 10/14/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrMnuUnityServer.h"

@implementation SvrMnuUnityServer

@synthesize serverInfo;

-(id) init {
    
    if((self = [super init]))
	{
        
    
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        NSError *error = nil;
	
        [udpSocket bindToPort:0 error:&error];
        [udpSocket beginReceiving:&error];

        NSString *host = @"67.225.180.24";
        host = @"127.0.0.1";
        int port = 23466;
        //NSString *msg = @"ÿÿÿÿTSource Engine Query";
        //NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        
        //const char bytes[] = "\xc0\x00\x00\x00\x00\xc3\xc8\xe4\x13\x00\x01\x01\x02\x00\x00";
        const char bytes[] = "\x09\x0b\xff\xff\xff\xff\xcf\x48\xda\x8d\x00\xff\xff\x00\xfe\xfe\xfe\xfe\xfd\xfd\xfd\xfd\x12\x34\x56\x78\xbc\x1e\x4b\xe7\x5b\xaa";
        
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
    NSLog(@"%@", data);
    NSLog(@"%@", address);
    return;
    

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
