//
//  LDNetworkLayer.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/21/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#import "LDNetworkDataProtocol.h"
#import "MessagePack.h"
#import "Net.h"

#define MAX_BUFF 1024 * 10

using namespace std;
using namespace net;

@interface LDNetworkLayer : NSObject
{
    Socket socket;
    
    id<LDNetworkDataProtocol> delegate;
    
    NSThread* serverLitenerThread;
    
    NSString* host;
    NSInteger port;
}

@property (strong) id<LDNetworkDataProtocol> delegate;

+(id)networkLayer;

-(void)startCommunication;
-(void)renameUser:(NSString*)oldName NewName:(NSString*)newName;
-(void)reconnect;
-(void)sendNSDataToServer:(NSData*)data;
@end

