//
//  LDVoiceRecordingThread.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDVoiceRecordingThread.h"

@implementation LDVoiceRecordingThread

+(id)recordingThreadWith:(LDNetworkLayer*)networkLayer with:(NSString*)userName
{
    return [[LDVoiceRecordingThread alloc] initWith:networkLayer with:userName];
}

-(id)initWith:(LDNetworkLayer*)_networkLayer with:(NSString*)_userName
{
    if (self = [super init]) {
        audioInputHandler  = LD_InitAudioInputHandler();
        networkLayer       = _networkLayer;
        userName           = _userName;
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
        Pa_Sleep(0.1f);
    });
}

-(void)renameUser:(NSString*)_userName
{
    userName = _userName;
}

-(void)recordingThreadLoop
{
    NSLog(@"Recording Thread Started");
    while (speaking) {
        if (silent) {
            Pa_Sleep(0.1f);
        } else {
            [self recordingThread];
        }
    }
    NSLog(@"Recording Thread End");
}

-(void)recordingThread
{
    @autoreleasepool {
        EncodedAudio buffer       = encodeAudio(audioInputHandler);
        NSDictionary *dict        = @{@"action": @"voice",
                                      @"name": userName,
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
