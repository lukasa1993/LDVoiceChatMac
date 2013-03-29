//
//  LDAudioInput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#ifndef LDAudioInput_h
#define LDAudioInput_h

#import "LDAudioDefaults.h"

EncodedAudio encodeAudio(AudioHandlerStruct *audioInputHandler);
AudioHandlerStruct *LD_InitAudioInputHandler();

void LD_StartRecordingStream(AudioHandlerStruct *audioInputHandler);
void LD_StopRecordingStream(AudioHandlerStruct *audioInputHandler);
void LD_DestroyRecordingStream(AudioHandlerStruct *audioInputHandler);
#endif