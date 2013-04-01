//
//  LDVoiceRecordingThread.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDVoiceRecordingThread.h"

@implementation LDVoiceRecordingThread

+(id)recordingThreadWith:(LDNetworkLayer*)networkLayer
{
    return [[LDVoiceRecordingThread alloc] initWith:networkLayer];
}

-(id)initWith:(LDNetworkLayer*)_networkLayer
{
    if (self = [super init]) {
        audioInputHandler  = LD_InitAudioInputHandler();
        networkLayer       = _networkLayer;
    }
    
    return self;
}

-(void)startRecordingThread
{
    speaking = YES;
    LD_StartRecordingStream(audioInputHandler);
    [NSThread detachNewThreadSelector:@selector(recordingThreadLoop) toTarget:self withObject:nil];
}

-(void)restartRecording // in case default input changed
{
    LD_StopRecordingStream(audioInputHandler);
    LD_DestroyRecordingStream(audioInputHandler);
    
    audioInputHandler  = LD_InitAudioInputHandler();
    LD_StartRecordingStream(audioInputHandler);
}

-(void)stopRecordingThread
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LD_StopRecordingStream(audioInputHandler);
        LD_DestroyRecordingStream(audioInputHandler);
        speaking = NO;
        wait(0.1f);
    });
}

-(void)recordingThreadLoop
{
    NSLog(@"Recording Thread Started");
    while (speaking) {
        if (silent) {
            wait(0.1f);
        } else {
            if (audioInputHandler->inputParameters.device != Pa_GetDefaultInputDevice()) {
                [self restartRecording];
            }
            [self recordingThread];
        }
    }
    NSLog(@"Recording Thread End");
}

-(void)recordingThread
{
    EncodedAudio buffer       = encodeAudio(audioInputHandler);
    NSDictionary *dict        = @{@"action": @"voice",
                                  @"name": [[NSUserDefaults standardUserDefaults] objectForKey:@"name"],
                                  @"audioDataLength": @(buffer.dataLength)};
    NSData        *dictPacked = [dict messagePack];
    unsigned char *sendBuff   = (unsigned char*) malloc([dictPacked length] + buffer.dataLength);
    
    memcpy(sendBuff,  [dictPacked bytes], [dictPacked length]);
    memcpy(sendBuff + [dictPacked length], buffer.data, buffer.dataLength);
    
    [networkLayer sendNSDataToServer:[NSData dataWithBytesNoCopy:sendBuff
                                                          length:[dictPacked length] + buffer.dataLength]];
    free(buffer.data);
    free(sendBuff);
}

@end
