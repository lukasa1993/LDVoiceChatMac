//
//  LDNetworkDataProtocol.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/22/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LDNetworkDataProtocol <NSObject>

-(void)userList:(NSArray*)userList;
-(void)communicationStarted;
-(void)incomingVoiceData:(NSData*)data;

@end
