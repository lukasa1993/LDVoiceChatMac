//
//  LDAudioOutput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioOutput.h"

static int playCallback(const void *inputBuffer, void *outputBuffer,
                        unsigned long framesPerBuffer,
                        const PaStreamCallbackTimeInfo* timeInfo,
                        PaStreamCallbackFlags statusFlags,
                        void *userData)
{
    RawAudioData* data  = (RawAudioData*)userData;
    ring_buffer_size_t elementsToPlay = PaUtil_GetRingBufferReadAvailable(&data->ringBuffer);
    ring_buffer_size_t elementsToRead = MIN(elementsToPlay, (ring_buffer_size_t)(framesPerBuffer * CHANELS));
    float* wptr = (float*)outputBuffer;
    
    for(int i = data->ringBuffer.readIndex;i < framesPerBuffer; i++)
    {
        wptr[i] = 0.0f;
    }
    
    PaUtil_ReadRingBuffer(&data->ringBuffer, wptr, elementsToRead);
    
    return paContinue;
}

AudioHandlerStruct* LD_InitAudioOutputHandler()
{
    AudioHandlerStruct* audioOutputHandler                         = (AudioHandlerStruct*) malloc(sizeof(AudioHandlerStruct));
    audioOutputHandler->outputParameters.device                    = Pa_GetDefaultOutputDevice();
    audioOutputHandler->outputParameters.channelCount              = CHANELS;
    audioOutputHandler->outputParameters.sampleFormat              = paFloat32;
    audioOutputHandler->outputParameters.suggestedLatency          =
    Pa_GetDeviceInfo(audioOutputHandler->outputParameters.device)->defaultLowOutputLatency;
    audioOutputHandler->outputParameters.hostApiSpecificStreamInfo = NULL;
    
    audioOutputHandler->userData = initRawAudioData();
    
    audioOutputHandler->paError = Pa_OpenStream(&audioOutputHandler->stream,
                                                NULL,
                                                &audioOutputHandler->outputParameters,
                                                SAMPLE_RATE,
                                                FRAMES,
                                                paClipOff,
                                                playCallback,
                                                audioOutputHandler->userData);
    
    
    return audioOutputHandler;
}

void LD_StartPlayebackStream(AudioHandlerStruct* audioOutputHandler)
{
    if (!Pa_IsStreamActive(audioOutputHandler->stream)) {
        audioOutputHandler->paError = Pa_StartStream(audioOutputHandler->stream);
    }
}

void LD_StopPlayebackStream(AudioHandlerStruct* audioOutputHandler)
{
    if (Pa_IsStreamActive(audioOutputHandler->stream)) {
        audioOutputHandler->paError = Pa_StopStream(audioOutputHandler->stream);
    }
}

RawAudioData* decodeAudio(AudioHandlerStruct* audioOutputHandler, EncodedAudioArr encoded)
{
    int           error   = 0;
    int           index   = 0;
    OpusDecoder*  dec     = opus_decoder_create(SAMPLE_RATE, CHANELS, &error);
    RawAudioData*  decoded = initRawAudioData();
    
    for(int i = 0; i < encoded.dataCount; i++){
        EncodedAudio *data = &encoded.data[i];
        
        int decompresed = opus_decode_float(dec,
                                            data->data,
                                            data->dataLength,
                                            decoded->audioArray + index,
                                            MAX_FRAME_SAMP,
                                            0);
        
        if (decompresed > 0 && decompresed <= MAX_FRAME_SAMP) {
            index += decompresed;
        } else {
            printf("Amis Dedasheveci Decode \n");
        }
        
        free(data->data);
    }
    
    opus_decoder_destroy(dec);
    free(encoded.data);
    
    return decoded;
}



