//
//  LDNetworkLayer.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/21/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#import "MessagePack.h"
#import "Net.h"


#define MAX_BUFF 512
#define HOST "localhost"
#define PORT 4444

using namespace std;
using namespace net;

@interface LDNetworkLayer : NSObject
{
    Socket socket;
    Address server;
}

+(id)networkLayer;

-(void)startCommunication;

@end
