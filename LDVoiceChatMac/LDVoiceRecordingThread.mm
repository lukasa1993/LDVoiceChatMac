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
        finalData         = [NSMutableData dataWithCapacity:MAX_BUFF];
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
    LD_StopRecordingStream(audioInputHandler);
    speaking = NO;
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
    LD_Buffer buffer = EncodedAudioArrToBuffer(encodeAudio(audioInputHandler->userData));
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"voice", @"action",
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"name"], @"name",
                          [NSNumber numberWithInt:buffer.bufferLength], @"audioDataLength",
                          nil];
    NSData *dictPacked = [dict messagePack];

    [finalData replaceBytesInRange:NSMakeRange(0, [dictPacked length]) withBytes:[dictPacked bytes]];
    
    [finalData replaceBytesInRange:NSMakeRange([dictPacked length], (NSUInteger) buffer.bufferLength)
                         withBytes:buffer.buffer];
    free(buffer.buffer);
    
    [networkLayer sendNSDataToServer:finalData];
    memset(audioInputHandler->userData->audioArray, 0, (size_t) audioInputHandler->userData->audioArrayByteLength);
    audioInputHandler->userData->audioArrayCurrentIndex = 0;
}

@end
