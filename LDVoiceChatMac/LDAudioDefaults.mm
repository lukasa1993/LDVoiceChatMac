//
//  LDAudioDefaults.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#include "LDAudioDefaults.h"

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

    RawAudioData* data           = (RawAudioData*) malloc(sizeof(RawAudioData));
    data->audioArrayLength       = SECONDS * SAMPLE_RATE;
    data->audioArrayByteLength   = data->audioArrayLength * sizeof(float);
    data->audioArrayCurrentIndex = 0;
    data->audioArray             = (float *) calloc(data->audioArrayLength, sizeof(float));
    
    return data;
}

void checkError(PaError err)
{
    if( err != paNoError )
    {
        fprintf( stderr, "An error occured while using the portaudio stream\n" );
        fprintf( stderr, "Error number: %d\n", err );
        fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
        assert(err == paNoError);
    }
}