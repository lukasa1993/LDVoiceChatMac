//
//  LDAudioInput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioInput.h"

AudioHandlerStruct *LD_InitAudioInputHandler()
{
    checkError(Pa_Initialize()); // Yeaaa
    
    AudioHandlerStruct *audioInputHandler               = (AudioHandlerStruct *) malloc(sizeof(AudioHandlerStruct));
    audioInputHandler->inputParameters.device           = Pa_GetDefaultInputDevice();
    audioInputHandler->inputParameters.channelCount     = CHANELS;
    audioInputHandler->inputParameters.sampleFormat     = paFloat32;
    audioInputHandler->inputParameters.suggestedLatency =
    Pa_GetDeviceInfo(audioInputHandler->inputParameters.device)->defaultLowInputLatency;
    audioInputHandler->inputParameters.hostApiSpecificStreamInfo = NULL;
    
    int error = 0;
    audioInputHandler->enc      = opus_encoder_create(SAMPLE_RATE, CHANELS, OPUS_APPLICATION_AUDIO, &error);
    audioInputHandler->userData = (char*) malloc(FRAMES * FRAMES_COUNT * 10);
    
    checkError(Pa_OpenStream(&audioInputHandler->stream,
                             &audioInputHandler->inputParameters,
                             NULL,
                             SAMPLE_RATE,
                             FRAMES,
                             paClipOff,
                             NULL,
                             NULL));
    
    return audioInputHandler;
}

void LD_StartRecordingStream(AudioHandlerStruct *audioInputHandler)
{
    if (!Pa_IsStreamActive(audioInputHandler->stream) && Pa_IsStreamStopped(audioInputHandler->stream)) {
        checkError(Pa_StartStream(audioInputHandler->stream));
    }
}

void LD_StopRecordingStream(AudioHandlerStruct *audioInputHandler)
{
    if (Pa_IsStreamActive(audioInputHandler->stream)) {
        checkError(Pa_StopStream(audioInputHandler->stream));
    }
}

void LD_DestroyRecordingStream(AudioHandlerStruct *audioInputHandler)
{
    opus_encoder_destroy(audioInputHandler->enc);
    Pa_CloseStream(audioInputHandler->stream);
    Pa_Terminate();
    free(audioInputHandler->userData);
    free(audioInputHandler);
}

EncodedAudio encodeAudio(AudioHandlerStruct *audioInputHandler)
{
    EncodedAudio   encoded       = {0};
    encoded.data                 = (unsigned char*) malloc(sizeof(int) + FRAMES_COUNT * (sizeof(int) + MAX_PACKET));
    encoded.dataLength           = sizeof(int);
    
    for (int i = 0; i < FRAMES_COUNT; i++) {
        Pa_ReadStream(audioInputHandler->stream, audioInputHandler->userData, FRAMES);
        encoded.dataLength += sizeof(int); // for datalength
        int dataLength      = opus_encode_float(audioInputHandler->enc,
                                                (float*) audioInputHandler->userData,
                                                FRAMES,
                                                encoded.data + encoded.dataLength,
                                                MAX_PACKET);
        
        memcpy(encoded.data + encoded.dataLength - sizeof(int), &dataLength, sizeof(int));
        
        encoded.dataLength += dataLength;
        if (dataLength <= 0 || dataLength >= MAX_PACKET) {
            printf("Amis Dedasheveci Encode \n");
            break;
        }
    }
    
    memcpy(encoded.data, &encoded.dataLength, sizeof(int));
    return encoded;
}


