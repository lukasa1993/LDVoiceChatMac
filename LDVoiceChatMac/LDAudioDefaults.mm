//
//  LDAudioDefaults.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#include "LDAudioDefaults.h"

void nulifyRecordedSamples(float* recordedSamples, int length)
{
    for(int i=0; i < length; i++) recordedSamples[i] = 0;
}

unsigned NextPowerOf2(unsigned val)
{
    val--;
    val = (val >> 1) | val;
    val = (val >> 2) | val;
    val = (val >> 4) | val;
    val = (val >> 8) | val;
    val = (val >> 16) | val;
    return ++val;
}

RawAudioData* initRawAudioData()
{

    RawAudioData* data         = (RawAudioData*) malloc(sizeof(RawAudioData));
    data->audioArrayLength     = NextPowerOf2(SECONDS * SAMPLE_RATE * CHANELS);
    data->audioArrayByteLength = data->audioArrayLength * sizeof(float);
    data->audioArray           = (float *) calloc(data->audioArrayLength, sizeof(float));
    
    PaUtil_InitializeRingBuffer(&data->ringBuffer, sizeof(float), data->audioArrayLength, data->audioArray);
    
    return data;
}
