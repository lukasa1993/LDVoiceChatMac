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
        audioInputHandler = LD_InitAudioInputHandler();
        networkLayer      = _networkLayer;
    }
    
    return self;
}

-(void)startRecordingThread
{
    speaking = YES;
    LD_StartRecordingStream(audioInputHandler);
    [NSThread detachNewThreadSelector:@selector(recordingThreadLoop) toTarget:self withObject:nil];
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
        [self recordingThread];
    }
    NSLog(@"Recording Thread End");
}

-(void)recordingThread
{
    wait(SECONDS_TO_WAIT);
    NSInteger tmp             = audioInputHandler->userData->audioArrayCurrentIndex;
    LD_Buffer buffer          = EncodedAudioArrToBuffer(encodeAudio(audioInputHandler->userData));
    NSDictionary *dict        = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"voice", @"action",
                                 [[NSUserDefaults standardUserDefaults] objectForKey:@"name"], @"name",
                                 [NSNumber numberWithInt:buffer.bufferLength], @"audioDataLength",
                                 nil];
    NSData        *dictPacked = [dict messagePack];
    unsigned char *sendBuff   = (unsigned char*) malloc([dictPacked length] + buffer.bufferLength);
    
    memcpy(sendBuff,  [dictPacked bytes], [dictPacked length]);
    memcpy(sendBuff + [dictPacked length], buffer.buffer, buffer.bufferLength);
    
    [networkLayer sendNSDataToServer:[NSData dataWithBytesNoCopy:sendBuff length:[dictPacked length] + buffer.bufferLength]];
    free(buffer.buffer);
    free(sendBuff);
    
    audioInputHandler->userData->audioArrayCurrentIndex -= tmp;
    memcpy(audioInputHandler->userData->audioArray,
           audioInputHandler->userData->audioArray + tmp,
           audioInputHandler->userData->audioArrayCurrentIndex * sizeof(float));
    
}

@end
