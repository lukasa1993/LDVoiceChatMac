//
//  LDVoiceRecordingThread.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDTransportPreparation.h"
#import "LDAudioInput.h"
#import "LDAudioOutput.h"
#import "LDNetworkLayer.h"

@interface LDVoiceRecordingThread : NSObject
{
    AudioHandlerStruct *audioInputHandler;
    AudioHandlerStruct *audioOutPutHandler;
    LDNetworkLayer     *networkLayer;
    BOOL                speaking;

}

+(id)recordingThreadWith:(LDNetworkLayer*)networkLayer;

-(void)startRecordingThread;
-(void)stopRecordingThread;

@end
