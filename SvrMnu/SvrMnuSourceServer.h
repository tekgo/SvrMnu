//
//  SvrMnuSourceServer.h
//  SvrMnu
//
//  Created by Patrick Winchell on 10/14/12.
//  Copyright (c) 2012 Super Party Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

typedef struct
{
	char version;
	char hostname[256];
	char map[32];
	char game_directory[32];
	char game_description[256];
	short app_id;
	char num_players ;
	char max_players;
	char num_of_bots;
	char dedicated;
	char os;
	char password;
	char secure;
	char game_version[32];
}SSQ_INFO_REPLY,*PSSQ_INFO_REPLY;

static inline void readString(NSData *data,int *index,char* buffer)
{
    char thisChar='\xFF';
    int i=0;
    int thisIndex=index[0];
    while (thisChar!='\x00') {
        [data getBytes:&thisChar range:NSMakeRange(thisIndex, 1)];
        buffer[i]=thisChar;
        thisIndex++;
        i++;
    }
    index[0]=thisIndex;
    
}

@interface SvrMnuSourceServer : NSObject {
        GCDAsyncUdpSocket *udpSocket;
    SSQ_INFO_REPLY serverInfo;
    
}

@property (nonatomic) SSQ_INFO_REPLY serverInfo;


@end
