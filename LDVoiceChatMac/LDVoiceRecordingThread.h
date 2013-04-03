//
//  LDVoiceRecordingThread.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDAudioInput.h"
#import "LDAudioOutput.h"
#import "LDNetworkLayer.h"

@interface LDVoiceRecordingThread : NSObject
{
    AudioHandlerStruct *audioInputHandler;
    LDNetworkLayer     *networkLayer;
    
    NSString           *userName;
    NSString           *channel;
    
    BOOL                speaking;
    BOOL                silent;
}


+ (id)recordingThreadWith:(LDNetworkLayer*)networkLayer;

- (void)mute;
- (BOOL)isMute;
- (void)unMute;

- (void)notifyChanges;
- (void)startRecordingThread;
- (void)stopRecordingThread;

@end
