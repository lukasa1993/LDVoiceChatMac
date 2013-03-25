//
//  LDUserVoiceThread.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDAudioOutput.h"
#import "LDTransportPreparation.h"

@interface LDUserVoiceThread : NSObject
{
    BOOL userSpeaks;
    AudioHandlerStruct *audioOutputHandler;
    NSMutableArray     *userVoice;
}

@property(strong) NSMutableArray *userVoice;

+(id)userVoiceThread;

-(void)startUserVoiceThread;
-(void)stopUserVoiceThread;
-(void)incoingVoice:(NSData*)data;

@end
