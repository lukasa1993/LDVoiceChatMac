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
#define MAX_FRAME_SAMP     (480)
#define MAX_PACKET         (240)
#define CHANELS            (1)
#define FRAMES             (480)
#define FRAMES_COUNT       (3) // n means n * 10 ms

typedef struct {
    PaStreamParameters inputParameters;
    PaStreamParameters outputParameters;
    PaStream *stream;
    char *userData;
    
    OpusDecoder *dec;
    OpusEncoder *enc;
} AudioHandlerStruct;

typedef struct {
    unsigned char *data;
    int dataLength;
} EncodedAudio;

void checkError(PaError err);

#endif

