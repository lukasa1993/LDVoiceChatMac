//
//  LDAudioInput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioDefaults.h"

AudioHandlerStruct* audioInputHandler;

static int recordCallback(const void *inputBuffer, void *outputBuffer,
                          unsigned long framesPerBuffer,
                          const PaStreamCallbackTimeInfo* timeInfo,
                          PaStreamCallbackFlags statusFlags,
                          void *userData)
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

EncodedAudioArr* encodeAudio(RawAudioData* data)
{
    int              error = 0;
    OpusEncoder*     enc;
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

    opus_encoder_destroy(enc);
//    free(data->recordedSamples);
//    free(data);
    return arr;
}

RawAudioData* recordRawAudio()
{
    RawAudioData* data    = (RawAudioData*) malloc(sizeof(RawAudioData));
    data->frameIndex      = 0;
    data->maxFrameIndex   = FRAME_SIZE; // FRAME_SIZE = second * rate
    data->bytesNeeded     = data->maxFrameIndex * CHANELS * sizeof(float);
    data->recordedSamples = (float *) malloc(data->bytesNeeded);
    for(int i=0; i < (data->maxFrameIndex * CHANELS); i++) {
        data->recordedSamples[i] = 0;
    }
    
    audioInputHandler->paError = Pa_OpenStream(
                                           &audioInputHandler->stream,
                                           &audioInputHandler->inputParameters,
                                           NULL,
                                           SAMPLE_RATE,
                                           FRAMES,
                                           paClipOff,
                                           recordCallback,
                                           data );
    
    audioInputHandler->paError = Pa_StartStream(audioInputHandler->stream);
    
    Pa_Sleep(SECONDS * 1000);
    //    Pa_CloseStream(handlerStruct->stream);
    return data;
}

void LD_InitAudioInputHandler()
{
    if (audioInputHandler != NULL) return;
    audioInputHandler = (AudioHandlerStruct*) malloc(sizeof(AudioHandlerStruct));
    audioInputHandler->paError = Pa_Initialize();
    audioInputHandler->inputParameters.device                    = Pa_GetDefaultInputDevice();
    audioInputHandler->inputParameters.channelCount              = CHANELS;
    audioInputHandler->inputParameters.sampleFormat              = paFloat32;
    audioInputHandler->inputParameters.suggestedLatency          =
    Pa_GetDeviceInfo(audioInputHandler->inputParameters.device)->defaultLowInputLatency;
    audioInputHandler->inputParameters.hostApiSpecificStreamInfo = NULL;
}

void LD_DestroyAudioInputHandler()
{
    Pa_CloseStream(audioInputHandler->stream);
    free(audioInputHandler);
}

EncodedAudioArr* LD_RecordAndEncodeAudio()
{
    LD_InitAudioInputHandler();
    return encodeAudio(recordRawAudio());
}