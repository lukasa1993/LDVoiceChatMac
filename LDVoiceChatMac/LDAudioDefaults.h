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
#include "pa_ringbuffer.h"
#include "pa_util.h"

#define SAMPLE_RATE        (48000)
#define MAX_FRAME_SAMP     (5760)
#define MAX_PACKET         (4000)
#define SECONDS            (0.501f)
#define SENDER_DIVIZION    (1.5f)
#define RECEIVER_DIVIZION  (4.5f)
#define CHANELS            (1)
#define FRAMES             (480)

typedef struct
{
    float*  audioArray;
    int     audioArrayLength;
    int     audioArrayByteLength;
    PaUtilRingBuffer    ringBuffer;
} RawAudioData;

typedef struct
{
    PaStreamParameters inputParameters;
    PaStreamParameters outputParameters;
    PaStream*          stream;
    PaError            paError;
    
    RawAudioData*       userData;
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


RawAudioData* initRawAudioData();
void nulifyRecordedSamples(float* recordedSamples, int length);

#endif
















