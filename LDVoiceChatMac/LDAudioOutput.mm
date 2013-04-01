//
//  LDAudioOutput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioOutput.h"

AudioHandlerStruct *LD_InitAudioOutputHandler() {
    AudioHandlerStruct *audioOutputHandler                = (AudioHandlerStruct *) malloc(sizeof(AudioHandlerStruct));
    audioOutputHandler->outputParameters.device           = Pa_GetDefaultOutputDevice();
    audioOutputHandler->outputParameters.channelCount     = CHANELS;
    audioOutputHandler->outputParameters.sampleFormat     = paFloat32;
    audioOutputHandler->outputParameters.suggestedLatency =
    Pa_GetDeviceInfo(audioOutputHandler->outputParameters.device)->defaultLowOutputLatency;
    audioOutputHandler->outputParameters.hostApiSpecificStreamInfo = NULL;
    
    int error                    = 0;
    audioOutputHandler->dec      = opus_decoder_create(SAMPLE_RATE, CHANELS, &error);
    audioOutputHandler->userData = (char*) malloc(FRAMES * FRAMES_COUNT * 10);
    
    checkError(Pa_OpenStream(&audioOutputHandler->stream,
                             NULL,
                             &audioOutputHandler->outputParameters,
                             SAMPLE_RATE,
                             FRAMES,
                             paClipOff,
                             NULL,
                             NULL));
    
    return audioOutputHandler;
}

void LD_StartPlayebackStream(AudioHandlerStruct *audioOutputHandler) {
    if (!Pa_IsStreamActive(audioOutputHandler->stream)) {
        checkError(Pa_StartStream(audioOutputHandler->stream));
    }
}

void LD_StopPlayebackStream(AudioHandlerStruct *audioOutputHandler) {
    if (Pa_IsStreamActive(audioOutputHandler->stream)) {
        checkError(Pa_StopStream(audioOutputHandler->stream));
    }
}

void LD_DestroyPlayebackStream(AudioHandlerStruct *audioOutputHandler) {
    opus_decoder_destroy(audioOutputHandler->dec);
    Pa_CloseStream(audioOutputHandler->stream);
    free(audioOutputHandler->userData);
    free(audioOutputHandler);
}

void decodeAudio(AudioHandlerStruct *audioOutputHandler, EncodedAudio encoded) {
    int encodedLength = 0, dataPointer = sizeof(int);
    memcpy(&encodedLength, encoded.data, sizeof(int));
    if (encodedLength < 1 || encodedLength > 1000) {
        NSLog(@"Corrupted Data Place: 1");
        return;
    }
    
    for (int i = 0; i < FRAMES_COUNT; i++) {
        int encFrameLength = 0;
        memcpy(&encFrameLength, encoded.data + dataPointer, sizeof(int));
        dataPointer += sizeof(int);
        if (encFrameLength < 1 || encFrameLength > FRAMES) {
            NSLog(@"Corrupted Data Place: 2");
            return;
        }
        
        int decompresed = opus_decode_float(audioOutputHandler->dec,
                                            encoded.data + dataPointer,
                                            encFrameLength,
                                            (float*) audioOutputHandler->userData,
                                            FRAMES,
                                            0);
        
        Pa_WriteStream(audioOutputHandler->stream, audioOutputHandler->userData, FRAMES);
        dataPointer += encFrameLength;
        if (!(decompresed > 0 && decompresed <= MAX_FRAME_SAMP)) {
            printf("Amis Dedasheveci Decode \n");
        }
    }
}



