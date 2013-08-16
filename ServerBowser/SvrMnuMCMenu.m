//
//  SvrMnuWFHMenu.m
//  SvrMnu
//
//  Created by Codemonkey on 10/15/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import "SvrMnuMCMenu.h"
#import "Reachability.h"

@implementation SvrMnuMCMenu
@synthesize delegate,value;
-(id) init {
    
    if((self = [super init]))
	{
        [self setTitle:@"Minecraft"];
        [self setSubmenu:[NSMenu alloc]];
        launcher = [[NSMenuItem alloc] initWithTitle:@"Launch MC" action:@selector(launchMC) keyEquivalent:@""];
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
    
            [self setTitle:@"MC-Refreshing..."];
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
    [Socket writeData:data withTimeout:15 tag:-1];
    [Socket readDataWithTimeout:15 tag:-1];
    updated=false;
}

-(void)makeMenus {
    [[self submenu] removeAllItems];
    //numServers=0;
    //numPlayers=0;
    NSString *titleString = @"MC-Unable to connect";
    value = numPlayers;
    if(numPlayers>0)
        titleString=@"MC-Players";
    if(numPlayers==0)
        titleString=@"MC-No Players";
    [self setTitle:titleString];
    [self updateDelegate];
    [[launcher menu] removeItem:launcher];
    [[self submenu] addItem:launcher];
}

-(void) updateDelegate{
    if(delegate!=nil && [delegate respondsToSelector:@selector(setTitle:)])
    {
        if(updated){
            [delegate setTitle:[NSString stringWithFormat:@"%d",numPlayers]];
        }
        else
            [delegate setTitle:nil];
    }
}

-(void)launchMC {
    //[[NSWorkspace sharedWorkspace] launchApplication:@"WaitingForHorus-osx"];
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.Mojang Specifications.Minecraft.Minecraft" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:NULL];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //NSLog(@"dataWrote");
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    //NSLog(@"dataGet");
    int index=9;
    char temp[[data length]];
        readMCString(data,&index,&temp[0]);//blank
        readMCString(data,&index,&temp[0]);//serverVersion
        readMCString(data,&index,&temp[0]);//serverMessage
        readMCString(data,&index,&temp[0]);//numplayers
        numPlayers = [[NSString stringWithCString:temp encoding:NSASCIIStringEncoding] intValue];
        readMCString(data,&index,&temp[0]);//maxplayers
        maxPlayers = [[NSString stringWithCString:temp encoding:NSASCIIStringEncoding] intValue];
        //NSLog([NSString stringWithCString:temp encoding:NSASCIIStringEncoding]);
    [sock disconnect];
    updated=true;
    [self performSelectorInBackground:@selector(makeMenus) withObject:nil];
    
}


- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    numPlayers = -1;
    [self performSelectorInBackground:@selector(makeMenus) withObject:nil];
     return -1;
    
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    numPlayers = -1;
    [self performSelectorInBackground:@selector(makeMenus) withObject:nil];
    return -1;
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if(err!=nil) {
    numPlayers = -1;
    [self performSelectorInBackground:@selector(makeMenus) withObject:nil];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    //NSLog(@"connect");
    
}

@end
