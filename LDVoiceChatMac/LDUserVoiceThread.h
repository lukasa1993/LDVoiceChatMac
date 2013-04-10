//
//  LDUserVoiceThread.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDAudioOutput.h"

@interface LDUserVoiceThread : NSObject
{
    BOOL userSpeaks;
    AudioHandlerStruct *audioOutputHandler;
    NSMutableArray     *userVoice;
    NSString           *userId;
}

@property(strong) NSMutableArray *userVoice;
@property(strong) NSString       *userId;

+(id)userVoiceThread;

-(void)startUserVoiceThread;
-(BOOL)isUserSpeaking;
-(void)stopUserVoiceThread;
-(void)incomingVoice:(NSData*)data;

@end
