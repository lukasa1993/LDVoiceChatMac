//
//  LDAudioOutput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#ifndef LDAudioOutput_h
#define LDAudioOutput_h

#import "LDAudioDefaults.h"

AudioHandlerStruct* LD_InitAudioOutputHandler();

void decodeAudio(AudioHandlerStruct* audioOutputHandler, EncodedAudioArr* encoded);
void LD_StartPlayebackStream(AudioHandlerStruct* audioOutputHandler);
void LD_StopPlayebackStream(AudioHandlerStruct* audioOutputHandler);
void LD_AddToPlayback(AudioHandlerStruct* audioOutputHandler, RawAudioData* data);
#endif