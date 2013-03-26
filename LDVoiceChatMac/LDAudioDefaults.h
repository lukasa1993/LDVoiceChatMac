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
#define SECONDS            (1.5f)
#define SECONDS_TO_WAIT    (1) // it is 0.5f but - 0.1f network wait time
#define CHANELS            (1)
#define FRAMES             (480)

typedef struct {
    float *audioArray;
    float audioArrayLength;
    float audioArrayMaxIndex;
    float audioArrayByteLength;
    float audioArrayCurrentIndex;
    
} RawAudioData;

typedef struct {
    PaStreamParameters inputParameters;
    PaStreamParameters outputParameters;
    PaStream *stream;
    RawAudioData *userData;
} AudioHandlerStruct;

typedef struct {
    unsigned char *data;
    int dataLength;
} EncodedAudio;

typedef struct {
    EncodedAudio *data;
    int dataCount;
    int dataLength;
} EncodedAudioArr;


RawAudioData *initRawAudioData();
void destroyRawAudioData(RawAudioData *data);
void checkError(PaError err);

#endif

