//
//  LDAudioOutput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioDefaults.h"

static int playCallback(const void *inputBuffer, void *outputBuffer,
                        unsigned long framesPerBuffer,
                        const PaStreamCallbackTimeInfo* timeInfo,
                        PaStreamCallbackFlags statusFlags,
                        void *userData)
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

void playDecodedAudio(AudioHandlerStruct* audioOutputHandler, RawAudioData* decoded)
{
    decoded->frameIndex = 0;
    audioOutputHandler->paError = Pa_OpenStream(
                                              &audioOutputHandler->stream,
                                              NULL,
                                              &audioOutputHandler->outputParameters,
                                              SAMPLE_RATE,
                                              FRAMES,
                                              paClipOff,
                                              playCallback,
                                              decoded );
    
    audioOutputHandler->paError = Pa_StartStream(audioOutputHandler->stream);
    
    Pa_Sleep(SECONDS * 1000);
    
    free(decoded->recordedSamples);
    free(decoded);
    //    Pa_CloseStream(handlerStruct->stream);
}

RawAudioData* decodeAudio(EncodedAudioArr* encoded)
{
    int           error      = 0;
    OpusDecoder*  dec        = opus_decoder_create(SAMPLE_RATE, CHANELS, &error);
    RawAudioData* decoded    = (RawAudioData*) malloc(sizeof(RawAudioData));
    
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

AudioHandlerStruct* LD_InitAudioOutputHandler()
{
    AudioHandlerStruct* audioOutputHandler = (AudioHandlerStruct*) malloc(sizeof(AudioHandlerStruct));
    audioOutputHandler->paError = Pa_Initialize();
    
    audioOutputHandler->outputParameters.device                    = Pa_GetDefaultOutputDevice();
    audioOutputHandler->outputParameters.channelCount              = CHANELS;
    audioOutputHandler->outputParameters.sampleFormat              = paFloat32;
    audioOutputHandler->outputParameters.suggestedLatency          =
    Pa_GetDeviceInfo(audioOutputHandler->outputParameters.device)->defaultLowOutputLatency;
    audioOutputHandler->outputParameters.hostApiSpecificStreamInfo = NULL;
    
    return audioOutputHandler;
}

void LD_DestroyAudioOutputHandler(AudioHandlerStruct* audioOutputHandler)
{
    Pa_CloseStream(audioOutputHandler->stream);
    free(audioOutputHandler);
}

void LD_DecodeAndPlayAudio(AudioHandlerStruct* audioOutputHandler, EncodedAudioArr* arr)
{
    playDecodedAudio(audioOutputHandler, decodeAudio(arr));
}


