//
//  LDAudioInput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioInput.h"

//static int recordCallback(const void *inputBuffer, void *outputBuffer,
//                          unsigned long framesPerBuffer,
//                          const PaStreamCallbackTimeInfo* timeInfo,
//                          PaStreamCallbackFlags statusFlags,
//                          void *userData)
//{
//    RawAudioData *data = (RawAudioData*)userData;
//    ring_buffer_size_t elementsWriteable = PaUtil_GetRingBufferWriteAvailable(&data->ringBuffer);
//    ring_buffer_size_t elementsToWrite = MIN(elementsWriteable, (ring_buffer_size_t)(framesPerBuffer * CHANELS));
//    const float* rptr = (const float*) inputBuffer;
//
//    for(int i = data->ringBuffer.writeIndex;i < elementsToWrite; i++)
//    {
//        data->audioArray[i] = 0.0f;
//    }
//
//    PaUtil_WriteRingBuffer(&data->ringBuffer, rptr, elementsToWrite);
//
//    return paContinue;
//}

static int recordCallback(const void *inputBuffer, void *outputBuffer,
        unsigned long framesPerBuffer,
        const PaStreamCallbackTimeInfo *timeInfo,
        PaStreamCallbackFlags statusFlags,
        void *userData) {
    RawAudioData *data = (RawAudioData *) userData;
    const float *rptr = (const float *) inputBuffer;
    float *wptr = &data->audioArray[(int) data->audioArrayCurrentIndex * CHANELS];
    long framesToCalc;
    long i;
    int finished;
    unsigned long framesLeft = data->audioArrayLength - data->audioArrayCurrentIndex;

    (void) outputBuffer; /* Prevent unused variable warnings. */
    (void) timeInfo;
    (void) statusFlags;
    (void) userData;

    if (framesLeft < framesPerBuffer) {
        framesToCalc = framesLeft;
        finished = paComplete;
    }
    else {
        framesToCalc = framesPerBuffer;
        finished = paContinue;
    }

    if (inputBuffer == NULL) {
        for (i = 0; i < framesToCalc; i++) {
            *wptr++ = 0.0f;  /* left */
            if (CHANELS == 2) *wptr++ = 0.0f;  /* right */
        }
    }
    else {
        for (i = 0; i < framesToCalc; i++) {
            *wptr++ = *rptr++;  /* left */
            if (CHANELS == 2) *wptr++ = *rptr++;  /* right */
        }
    }
    data->audioArrayCurrentIndex += framesToCalc;

    if (finished == paComplete) {
        finished = paContinue;
    }

    return finished;
}


AudioHandlerStruct *LD_InitAudioInputHandler() {
    AudioHandlerStruct *audioInputHandler = (AudioHandlerStruct *) malloc(sizeof(AudioHandlerStruct));
    checkError(Pa_Initialize());
    audioInputHandler->inputParameters.device = Pa_GetDefaultInputDevice();
    audioInputHandler->inputParameters.channelCount = CHANELS;
    audioInputHandler->inputParameters.sampleFormat = paFloat32;
    audioInputHandler->inputParameters.suggestedLatency =
            Pa_GetDeviceInfo(audioInputHandler->inputParameters.device)->defaultLowInputLatency;
    audioInputHandler->inputParameters.hostApiSpecificStreamInfo = NULL;

    audioInputHandler->userData = initRawAudioData();

    checkError(Pa_OpenStream(&audioInputHandler->stream,
            &audioInputHandler->inputParameters,
            NULL,
            SAMPLE_RATE,
            FRAMES,
            paClipOff,
            recordCallback,
            audioInputHandler->userData));

    return audioInputHandler;
}


void LD_StartRecordingStream(AudioHandlerStruct *audioInputHandler) {
    if (!Pa_IsStreamActive(audioInputHandler->stream) && Pa_IsStreamStopped(audioInputHandler->stream)) {
        checkError(Pa_StartStream(audioInputHandler->stream));
    }
}

void LD_StopRecordingStream(AudioHandlerStruct *audioInputHandler) {
    if (Pa_IsStreamActive(audioInputHandler->stream)) {
        checkError(Pa_StopStream(audioInputHandler->stream));
    }
}

void LD_DestroyRecordingStream(AudioHandlerStruct *audioInputHandler) {
    Pa_CloseStream(audioInputHandler->stream);
    Pa_Terminate();
    destroyRawAudioData(audioInputHandler->userData);
    free(audioInputHandler);
}

EncodedAudioArr encodeAudio(RawAudioData *data) {
    
    int             error;
    OpusEncoder    *enc;
    EncodedAudioArr arr;

    error         = 0;
    enc           = opus_encoder_create(SAMPLE_RATE, CHANELS, OPUS_APPLICATION_VOIP, &error);
    arr           = {0};
    arr.dataCount = (data->audioArrayCurrentIndex / FRAMES);
    arr.data      = (EncodedAudio *) malloc(arr.dataCount * sizeof(EncodedAudio));
    
    for (int i = 0; i < arr.dataCount; i++) {
        EncodedAudio *encodedData = &arr.data[i];
        float *frame = data->audioArray + (FRAMES * i);

        encodedData->data       = (unsigned char *) calloc(MAX_PACKET, sizeof(unsigned char));
        encodedData->dataLength = opus_encode_float(enc, frame, FRAMES, encodedData->data, MAX_PACKET);
        arr.dataLength         += encodedData->dataLength;

        if (encodedData->dataLength < 0 || encodedData->dataLength > MAX_PACKET) {
            printf("Amis Dedasheveci Encode \n");
            break;
        }
    }

    opus_encoder_destroy(enc);
    return arr;
}




