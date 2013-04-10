//
//  LDUserVoiceThread.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDUserVoiceThread.h"

@implementation LDUserVoiceThread
@synthesize userVoice;
@synthesize userId;

+ (id)userVoiceThread
{
    return [[LDUserVoiceThread alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        userVoice          = [NSMutableArray array];
    }
    return self;
}

- (void)startUserVoiceThread
{
    if (userSpeaks) {
        NSLog(@"Thread Already Running");
        return;
    }
    userSpeaks = YES;
    audioOutputHandler = LD_InitAudioOutputHandler();
    LD_StartPlayebackStream(audioOutputHandler);
    [self userSpeakingLoop];
}

- (BOOL)isUserSpeaking
{
    return userSpeaks;
}

- (void)stopUserVoiceThread
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (userSpeaks) {
            LD_DestroyPlayebackStream(audioOutputHandler);
            userSpeaks = NO;
            usleep((int) (0.1f * 1000000.0f));
        }
//    });
}

- (void)userSpeakingLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"User voice Thread Started");
        while (userSpeaks) {
            [self userSpeaking];
        }
        NSLog(@"User voice Thread End");
    });
    [userVoice removeAllObjects];
}

- (void)incomingVoice:(NSData*)data
{
    if (userSpeaks) {
        [userVoice addObject:data];
    }
}

- (void)userSpeaking
{
    @autoreleasepool {
        if ([userVoice count] > 0) {
            if ([userVoice count] > 1) {
                NSLog(@"Count: %li", (unsigned long) [userVoice count]);
            }
            
            NSData    *audio = nil;
            NSInteger i      = 0;
            do {
                audio = [userVoice[i] copy];
                [userVoice removeObjectAtIndex:i];
                i++;
                if (i >= [userVoice count]) {
                    [userVoice removeAllObjects];
                    break;
                }
            } while (audio != nil);
            
            if (!audio) {
                NSLog(@"Shen Shig Xoar AR GAK?");
            } else {
                EncodedAudio arr     = {0};
                arr.data             = (unsigned char *) [audio bytes];
                arr.dataLength       = (int)             [audio length];
                int checkDataLength  = 0;
                memcpy(&checkDataLength, arr.data, sizeof(int));
                
                if ((arr.dataLength < 0 || arr.dataLength > 10000) && (arr.dataLength != checkDataLength)) {
                    printf("Received Corrupted Data \n");
                } else {
                    decodeAudio(audioOutputHandler, arr);
                }
            }
        } else {
            usleep((int) (0.01f * 1000000.0f));
        }
    }
}

@end
