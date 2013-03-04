//
//  LDAudioDefaults.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#ifndef LDVoiceChatMac_LDAudioDefaults_h
#define LDVoiceChatMac_LDAudioDefaults_h

#include <stdlib.h>
#include <stdio.h>
#include "portaudio.h"
#include "opus.h"

#define SAMPLE_RATE        (48000)
#define MAX_FRAME_SAMP     (5760)
#define MAX_PACKET         (4000)
#define SECONDS            (0.25f)
#define SECONDS_FOR_BUFFER (0.75f)
#define CHANELS            (1)
#define FRAMES             (480)

typedef struct
{
    int     frameIndex;
    int     secondFrameIndex;
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
    
    void*              userData;
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


RawAudioData* initRawAudioData(float seconds);
void nulifyRecordedSamples(float* recordedSamples, int length);

#endif
















