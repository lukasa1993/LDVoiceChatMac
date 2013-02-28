//
//  LDAudioHandler.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/22/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#ifndef LDAUDIOHANDLER
#define LDAUDIOHANDLER

#include <stdlib.h>
#include <stdio.h>
#include "portaudio.h"
#include "opus.h"

#define SAMPLE_RATE    (24000)
#define MAX_FRAME_SAMP (5760)
#define MAX_PACKET     (4000)
#define SECONDS        (0.2f)
#define CHANELS        (1)
#define FRAMES         (120)
#define FRAME_SIZE     SECONDS * SAMPLE_RATE

typedef struct
{
    int     frameIndex;
    int     maxFrameIndex;
    int     bytesNeeded;
    float*  recordedSamples;
} RawAudioData;

typedef struct
{
    PaStreamParameters inputParameters;
    PaStreamParameters outputParameters;
    PaStream*          stream;
    PaError            paError;
    
    RawAudioData* data;
} AudioHandlerStruct;

typedef struct
{
    unsigned char* data;
    int dataLength;
} EncodedAudio;

typedef struct
{
    EncodedAudio* data;
    int dataCount;
    int dataLength;
} EncodedAudioArr;


AudioHandlerStruct* LD_InitAudioHandler();
void LD_DestroyAudioHandler(AudioHandlerStruct* handlerStruct);

EncodedAudioArr* LD_RecordAndEncodeAudio(AudioHandlerStruct* handlerStruct);
void LD_DecodeAndPlayAudio(AudioHandlerStruct* handlerStruct, EncodedAudioArr* encodedAudio);

#endif