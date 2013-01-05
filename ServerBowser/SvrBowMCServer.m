//
//  SvrBowSourceServer.m
//  ServerBowser
//
//  Created by Patrick Winchell on 10/14/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrBowMCServer.h"
#import "GCDAsyncSocket.h"

@implementation SvrBowMCServer


-(id) init {
    
    if((self = [super init]))
	{
        
    
        Socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
       

        NSString *host = @"mc.superpartyawesome.com";
        int port = 25565;
        
        NSError *err = nil;
        if (![Socket connectToHost:host onPort:port error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSLog(@"I goofed: %@", err);
        }
        //[Socket sendData:data toHost:host port:port withTimeout:15 tag:1];
        const char bytes[] = "\xFE\x01";
        size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
        
        NSData *data = [NSData dataWithBytes:bytes length:length];
        buffer = [NSData new];
        [Socket writeData:data withTimeout:-1 tag:-1];
        [Socket readDataWithTimeout:-1 tag:-1];
        //[Socket readDataToLength:100 withTimeout:-1 tag:-1];
        //[Socket readDataToData:buffer withTimeout:-1 tag:-1];
    }
    return self;
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //NSLog(@"dataWrote");
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    //NSLog(@"dataGet");
    int index=9;
    char temp[[data length]];
    while (index<[data length]) {
        readMCString(data,&index,&temp[0]);
        NSLog([NSString stringWithCString:temp encoding:NSASCIIStringEncoding]);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    //NSLog(@"connect");

}



@end
