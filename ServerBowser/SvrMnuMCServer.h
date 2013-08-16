//
//  SvrMnuSourceServer.h
//  SvrMnu
//
//  Created by Patrick Winchell on 10/14/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

static inline void readMCString(NSData *data,int *index,char* buffer)
{
    char thisChar='\xFF';
    int i=0;
    int thisIndex=index[0];
    int lastChar=false;
    while ((thisChar!='\x00' || !lastChar) && thisIndex<[data length]) {
        if(thisChar=='\x00')
            lastChar=true;
        else
            lastChar=false;
        [data getBytes:&thisChar range:NSMakeRange(thisIndex, 1)];
        if(thisChar!='\x00') {
            buffer[i]=thisChar;
            i++;
        }
        thisIndex++;
    }
    buffer[i]='\x00';
    index[0]=thisIndex;
    
}

@interface SvrMnuMCServer : NSObject {
        GCDAsyncSocket *Socket;
    NSData *buffer;
    
}




@end
