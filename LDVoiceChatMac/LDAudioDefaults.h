//
//  LDAudioDefaults.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#ifndef LDVoiceChatMac_LDAudioDefaults_h
#define LDVoiceChatMac_LDAudioDefaults_h 1

#include <stdlib.h>
#include <stdio.h>
#include "portaudio.h"
#include "opus.h"
#include "pa_ringbuffer.h"
#include "pa_util.h"

#define SAMPLE_RATE    (24000)
#define MAX_FRAME_SAMP (5760)
#define MAX_PACKET     (4000)
#define SECONDS        (0.5f)
#define CHANELS        (1)
#define FRAMES         (120)
#define FRAME_SIZE     SECONDS * SAMPLE_RATE

typedef struct
{
    int     frameIndex;
    int     maxFrameIndex;
    int     bytesNeeded;
    float*  recordedSamples;
    PaUtilRingBuffer    ringBuffer;
} RawAudioData;

typedef struct
{
    unsigned         frameIndex;
    int              threadSyncFlag;
    float*           ringBufferData;
    PaUtilRingBuffer ringBuffer;
    void*            threadHandle;
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


#endif
