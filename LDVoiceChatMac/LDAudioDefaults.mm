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

RawAudioData* initRawAudioData(float seconds)
{
    RawAudioData* data     = (RawAudioData*) malloc(sizeof(RawAudioData));
    data->frameIndex       = 0;
    data->secondFrameIndex = 0;
    data->maxFrameIndex    = seconds * SAMPLE_RATE;
    data->bytesNeeded      = data->maxFrameIndex * CHANELS * sizeof(float);
    data->recordedSamples  = (float *) malloc(data->bytesNeeded);
    nulifyRecordedSamples(data->recordedSamples, data->maxFrameIndex * CHANELS);
    
    return data;
}
