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
    
    BOOL                speaking;
    BOOL                silent;
}


+(id)recordingThreadWith:(LDNetworkLayer*)networkLayer with:(NSString*)userName;

-(void)renameUser:(NSString*)_userName;
-(void)startRecordingThread;
-(void)stopRecordingThread;

@end
