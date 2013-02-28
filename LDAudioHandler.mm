//
//  LDAudioHandler.c
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/25/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#include "LDAudioHandler.h"

EncodedAudioArr* encodeAudio(RawAudioData* data)
{
    int            error = 0;
    OpusEncoder*   enc;
    EncodedAudioArr* arr;
    
    enc             = opus_encoder_create(SAMPLE_RATE, CHANELS, OPUS_APPLICATION_VOIP, &error);
    arr             = (EncodedAudioArr*) malloc(sizeof(EncodedAudioArr));
    arr->dataLength = 0;
    arr->dataCount  = (data->maxFrameIndex / FRAMES);
    arr->data       = (EncodedAudio*)  malloc(arr->dataCount *  sizeof(EncodedAudio));
    
    
    for(int i = 0; i < arr->dataCount; i++){
        EncodedAudio *encodedData = &arr->data[i];
        float* frame = data->recordedSamples + (FRAMES * i);
        
        encodedData->data       = (unsigned char*) malloc(MAX_PACKET * sizeof(unsigned char));
        encodedData->dataLength = opus_encode_float(enc, frame, FRAMES, encodedData->data, MAX_PACKET);
        arr->dataLength        += encodedData->dataLength;
        
        if (!(encodedData->dataLength > 0 && encodedData->dataLength < MAX_PACKET)) {
            printf("Amis Dedasheveci Encode \n");
            break;
        }
    }
    
    NSLog(@"%i -> %i \n", data->bytesNeeded, arr->dataLength);
    
    opus_encoder_destroy(enc);
    free(data->recordedSamples);
    free(data);
    return arr;
}

RawAudioData* decodeAudio(EncodedAudioArr* encoded)
{
    int            error = 0;
    OpusDecoder*   dec;
    RawAudioData*  decoded;
    
    dec                      = opus_decoder_create(SAMPLE_RATE, CHANELS, &error);
    decoded                  = (RawAudioData*) malloc(sizeof(RawAudioData));
    decoded->frameIndex      = 0;
    decoded->maxFrameIndex   = 0;
    decoded->bytesNeeded     = FRAME_SIZE * CHANELS * sizeof(float);
    decoded->recordedSamples = (float *) malloc(decoded->bytesNeeded);
    
    for(int i = 0; i < encoded->dataCount; i++){
        EncodedAudio *data = &encoded->data[i];
        
        int decompresed = opus_decode_float(dec,
                                            data->data,
                                            data->dataLength,
                                            decoded->recordedSamples + decoded->maxFrameIndex,
                                            MAX_FRAME_SAMP,
                                            0);
        
        if (decompresed > 0 && decompresed <= MAX_FRAME_SAMP) {
            decoded->maxFrameIndex += decompresed;
        } else {
            printf("Amis Dedasheveci Decode \n");
        }
    }
    
    opus_decoder_destroy(dec);
    free(encoded->data);
    free(encoded);
    return decoded;
}

static int recordCallback( const void *inputBuffer, void *outputBuffer,
                          unsigned long framesPerBuffer,
                          const PaStreamCallbackTimeInfo* timeInfo,
                          PaStreamCallbackFlags statusFlags,
                          void *userData )
{
    RawAudioData *data = (RawAudioData*)userData;
    const float *rptr = (const float*)inputBuffer;
    float *wptr = &data->recordedSamples[data->frameIndex * CHANELS];
    long framesToCalc;
    long i;
    int finished;
    unsigned long framesLeft = data->maxFrameIndex - data->frameIndex;
    
    (void) outputBuffer; /* Prevent unused variable warnings. */
    (void) timeInfo;
    (void) statusFlags;
    (void) userData;
    
    if( framesLeft < framesPerBuffer )
    {
        framesToCalc = framesLeft;
        finished = paComplete;
    }
    else
    {
        framesToCalc = framesPerBuffer;
        finished = paContinue;
    }
    
    if( inputBuffer == NULL )
    {
        for( i=0; i<framesToCalc; i++ )
        {
            *wptr++ = 0.0f;  /* left */
            if( CHANELS == 2 ) *wptr++ = 0.0f;  /* right */
        }
    }
    else
    {
        for( i=0; i<framesToCalc; i++ )
        {
            *wptr++ = *rptr++;  /* left */
            if( CHANELS == 2 ) *wptr++ = *rptr++;  /* right */
        }
    }
    data->frameIndex += framesToCalc;
    return finished;
}


static int playCallback( const void *inputBuffer, void *outputBuffer,
                        unsigned long framesPerBuffer,
                        const PaStreamCallbackTimeInfo* timeInfo,
                        PaStreamCallbackFlags statusFlags,
                        void *userData )
{
    RawAudioData *data = (RawAudioData*)userData;
    float *rptr = &data->recordedSamples[data->frameIndex * CHANELS];
    float *wptr = (float*)outputBuffer;
    unsigned int i;
    int finished;
    unsigned int framesLeft = data->maxFrameIndex - data->frameIndex;
    
    (void) inputBuffer; /* Prevent unused variable warnings. */
    (void) timeInfo;
    (void) statusFlags;
    (void) userData;
    
    if( framesLeft < framesPerBuffer )
    {
        /* final buffer... */
        for( i=0; i<framesLeft; i++ )
        {
            *wptr++ = *rptr++;  /* left */
            if( CHANELS == 2 ) *wptr++ = *rptr++;  /* right */
        }
        for( ; i<framesPerBuffer; i++ )
        {
            *wptr++ = 0;  /* left */
            if( CHANELS == 2 ) *wptr++ = 0;  /* right */
        }
        data->frameIndex += framesLeft;
        finished = paComplete;
    }
    else
    {
        for( i=0; i<framesPerBuffer; i++ )
        {
            *wptr++ = *rptr++;  /* left */
            if( CHANELS == 2 ) *wptr++ = *rptr++;  /* right */
        }
        data->frameIndex += framesPerBuffer;
        finished = paContinue;
    }
    return finished;
}

AudioHandlerStruct* LD_InitAudioHandler()
{
    AudioHandlerStruct* handler;
    handler = (AudioHandlerStruct*) malloc(sizeof(AudioHandlerStruct));
    
    handler->paError = Pa_Initialize();
    
    handler->inputParameters.device                    = Pa_GetDefaultInputDevice();
    handler->inputParameters.channelCount              = CHANELS;
    handler->inputParameters.sampleFormat              = paFloat32;
    handler->inputParameters.suggestedLatency          =
    Pa_GetDeviceInfo(handler->inputParameters.device)->defaultLowInputLatency;
    handler->inputParameters.hostApiSpecificStreamInfo = NULL;
    
    handler->outputParameters.device                    = Pa_GetDefaultOutputDevice();
    handler->outputParameters.channelCount              = CHANELS;
    handler->outputParameters.sampleFormat              = paFloat32;
    handler->outputParameters.suggestedLatency          =
    Pa_GetDeviceInfo(handler->outputParameters.device)->defaultLowOutputLatency;
    handler->outputParameters.hostApiSpecificStreamInfo = NULL;
    
    return handler;
}

void recordRawAudio(AudioHandlerStruct* handlerStruct)
{
    handlerStruct->data                  = (RawAudioData*) malloc(sizeof(RawAudioData));
    handlerStruct->data->frameIndex      = 0;
    handlerStruct->data->maxFrameIndex   = FRAME_SIZE; // FRAME_SIZE = second * rate
    handlerStruct->data->bytesNeeded     = handlerStruct->data->maxFrameIndex * CHANELS * sizeof(float);
    handlerStruct->data->recordedSamples = (float *) malloc(handlerStruct->data->bytesNeeded);
    for(int i=0; i < (handlerStruct->data->maxFrameIndex * CHANELS); i++) handlerStruct->data->recordedSamples[i] = 0;
    
    handlerStruct->paError = Pa_OpenStream(
                                           &handlerStruct->stream,
                                           &handlerStruct->inputParameters,
                                           NULL,
                                           SAMPLE_RATE,
                                           FRAMES,
                                           paClipOff,
                                           recordCallback,
                                           handlerStruct->data );
    
    handlerStruct->paError = Pa_StartStream(handlerStruct->stream);
    
    Pa_Sleep(SECONDS * 1000);
    Pa_CloseStream(handlerStruct->stream);
}

void playDecodedAudio(AudioHandlerStruct* handlerStruct, RawAudioData* decoded)
{
    decoded->frameIndex = 0;
    handlerStruct->paError = Pa_OpenStream(
                                           &handlerStruct->stream,
                                           NULL,
                                           &handlerStruct->outputParameters,
                                           SAMPLE_RATE,
                                           FRAMES,
                                           paClipOff,
                                           playCallback,
                                           decoded );
    
    handlerStruct->paError = Pa_StartStream(handlerStruct->stream);
    
    while((handlerStruct->paError = Pa_IsStreamActive(handlerStruct->stream)) == 1 ) Pa_Sleep(100);
    
    Pa_CloseStream(handlerStruct->stream);
}

EncodedAudioArr* LD_RecordAndEncodeAudio(AudioHandlerStruct* handlerStruct)
{
    recordRawAudio(handlerStruct);
    EncodedAudioArr* encodedData = encodeAudio(handlerStruct->data);
    LD_DestroyAudioHandler(handlerStruct);
    return encodedData;
}

void LD_DecodeAndPlayAudio(AudioHandlerStruct* handlerStruct, EncodedAudioArr* encodedAudio)
{
    RawAudioData* decoded = decodeAudio(encodedAudio);
    playDecodedAudio(handlerStruct, decoded);
    LD_DestroyAudioHandler(handlerStruct);
    
    free(decoded->recordedSamples);
    free(decoded);
}

void LD_DestroyAudioHandler(AudioHandlerStruct* handlerStruct)
{
    free(handlerStruct);
    Pa_Terminate();
}