//
//  LDVoiceRecordingThread.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDVoiceRecordingThread.h"

@implementation LDVoiceRecordingThread

+ (id)recordingThreadWith:(LDNetworkLayer*)networkLayer
{
    return [[LDVoiceRecordingThread alloc] initWith:networkLayer];
}

- (id)initWith:(LDNetworkLayer*)_networkLayer
{
    if (self = [super init]) {
        networkLayer       = _networkLayer;
        silent             = YES;
        
        [self notifyChanges];
    }
    
    return self;
}

- (void)startRecordingThread
{
    if (speaking) {
        NSLog(@"Voice Thread Already Running");
    }
    speaking = YES;
    audioInputHandler  = LD_InitAudioInputHandler();
    LD_StartRecordingStream(audioInputHandler);
    [self recordingThreadLoop];
}

- (void)stopRecordingThread
{
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    speaking = NO;
    usleep((int) (0.1f * 1000000.0f));
    LD_StopRecordingStream(audioInputHandler);
    LD_DestroyRecordingStream(audioInputHandler);
    //    });
}

- (void)notifyChanges
{
    userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    channel  = [[NSUserDefaults standardUserDefaults] objectForKey:@"channel"];
}

- (void)mute
{
    silent = YES;
}

- (BOOL)isMute
{
    return silent;
}

- (void)unMute
{
    silent = NO;
}

- (void)recordingThreadLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Recording Thread Started");
        while (speaking) {
            if (silent) {
                usleep((int) (0.1f * 1000000.0f));
            } else {
                [self recordingThread];
            }
        }
        NSLog(@"Recording Thread End");
    });
}

- (void)recordingThread
{
    @autoreleasepool {
        EncodedAudio buffer       = encodeAudio(audioInputHandler);
        NSDictionary *dict        = @{@"action"         : @"voice",
                                      @"name"           : userName,
                                      @"channel"        : channel,
                                      @"audioDataLength": @(buffer.dataLength)};
        NSData        *dictPacked = [dict messagePack];
        unsigned char *sendBuff   = (unsigned char*) malloc([dictPacked length] + buffer.dataLength);
        
        memcpy(sendBuff,  [dictPacked bytes], [dictPacked length]);
        memcpy(sendBuff + [dictPacked length], buffer.data, buffer.dataLength);
        
        [networkLayer sendData:sendBuff length:[dictPacked length] + buffer.dataLength];
        
        free(buffer.data);
        free(sendBuff);
    }
}

@end
