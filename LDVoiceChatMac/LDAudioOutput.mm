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
        const PaStreamCallbackTimeInfo *timeInfo,
        PaStreamCallbackFlags statusFlags,
        void *userData) {
    RawAudioData *data = (RawAudioData *) userData;
    float *rptr = &data->audioArray[data->audioArrayCurrentIndex * CHANELS];
    float *wptr = (float *) outputBuffer;
    unsigned int i;
    int finished;
    unsigned int framesLeft = data->audioArrayLength - data->audioArrayCurrentIndex;

    (void) inputBuffer; /* Prevent unused variable warnings. */
    (void) timeInfo;
    (void) statusFlags;
    (void) userData;

    if (framesLeft < framesPerBuffer) {
        /* final buffer... */
        for (i = 0; i < framesLeft; i++) {
            *wptr++ = *rptr++;  /* left */
            if (CHANELS == 2) *wptr++ = *rptr++;  /* right */
        }
        for (; i < framesPerBuffer; i++) {
            *wptr++ = 0;  /* left */
            if (CHANELS == 2) *wptr++ = 0;  /* right */
        }
        data->audioArrayCurrentIndex += framesLeft;
        finished = paComplete;
    }
    else {
        for (i = 0; i < framesPerBuffer; i++) {
            *wptr++ = *rptr++;  /* left */
            if (CHANELS == 2) *wptr++ = *rptr++;  /* right */
        }
        data->audioArrayCurrentIndex += framesPerBuffer;
        finished = paContinue;
    }

    if (finished == paComplete) {
        finished = paContinue;
//        data->audioArrayCurrentIndex = 0;
    }

    return finished;
}

AudioHandlerStruct *LD_InitAudioOutputHandler() {
    AudioHandlerStruct *audioOutputHandler = (AudioHandlerStruct *) malloc(sizeof(AudioHandlerStruct));
    audioOutputHandler->outputParameters.device = Pa_GetDefaultOutputDevice();
    audioOutputHandler->outputParameters.channelCount = CHANELS;
    audioOutputHandler->outputParameters.sampleFormat = paFloat32;
    audioOutputHandler->outputParameters.suggestedLatency =
            Pa_GetDeviceInfo(audioOutputHandler->outputParameters.device)->defaultLowOutputLatency;
    audioOutputHandler->outputParameters.hostApiSpecificStreamInfo = NULL;

    audioOutputHandler->userData = initRawAudioData();

    checkError(Pa_OpenStream(&audioOutputHandler->stream,
            NULL,
            &audioOutputHandler->outputParameters,
            SAMPLE_RATE,
            FRAMES,
            paClipOff,
            playCallback,
            audioOutputHandler->userData));

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

RawAudioData *decodeAudio(AudioHandlerStruct *audioOutputHandler, EncodedAudioArr encoded) {
    int error = 0;
    int index = 0;
    OpusDecoder *dec = opus_decoder_create(SAMPLE_RATE, CHANELS, &error);
    RawAudioData *decoded = initRawAudioData();

    for (int i = 0; i < encoded.dataCount; i++) {
        EncodedAudio *data = &encoded.data[i];

        int decompresed = opus_decode_float(dec,
                data->data,
                data->dataLength,
                decoded->audioArray + index,
                MAX_FRAME_SAMP,
                0);

        free(data->data);
        if (decompresed > 0 && decompresed <= MAX_FRAME_SAMP) {
            index += decompresed;
        } else {
            printf("Amis Dedasheveci Decode \n");
        }
    }

    opus_decoder_destroy(dec);
    free(encoded.data);

    return decoded;
}



