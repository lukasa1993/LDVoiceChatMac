//
//  LDTransportPreparation.c
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/27/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#include <string.h>
#include <stdio.h>
#import "LDAudioDefaults.h"

typedef struct
{
    unsigned char* buffer;
    int            bufferLength;
} LD_Buffer;

LD_Buffer EncodedAudioArrToBuffer(EncodedAudioArr encodedData)
{
    int pointerPlase          = 0;
    LD_Buffer bufferStruct    = {0};
    bufferStruct.bufferLength = encodedData.dataLength + (sizeof(int) * (encodedData.dataCount + 1)); // + 1 for
    bufferStruct.buffer       = (unsigned char*) malloc(bufferStruct.bufferLength);
    
    memcpy(bufferStruct.buffer + pointerPlase, &encodedData.dataCount, sizeof(int)); // this
    pointerPlase += sizeof(int);
    
    for (int i = 0; i < encodedData.dataCount; i++) {
        EncodedAudio*  encodedAudio           = &encodedData.data[i];
        unsigned char* encodedAudioData       = encodedAudio->data;
        int            encodedAudioDataLength = encodedAudio->dataLength;
        
        memcpy(bufferStruct.buffer + pointerPlase, &encodedAudioDataLength, sizeof(int));
        pointerPlase += sizeof(int);
        memcpy(bufferStruct.buffer + pointerPlase, encodedAudioData, encodedAudioDataLength);
        pointerPlase += encodedAudioDataLength;
        
        free(encodedAudioData);
    }
    
    free(encodedData.data);
    return bufferStruct;
}

EncodedAudioArr BufferToEncodedAudioArr(LD_Buffer* buffer)
{
    EncodedAudioArr arr  = {0};
    int pointerPlase     = 0;
    
    memcpy(&arr.dataCount, buffer->buffer + pointerPlase, sizeof(int));
    pointerPlase        += sizeof(int);
    
    arr.dataLength = buffer->bufferLength - (sizeof(int) * (arr.dataCount + 1));
    arr.data       = (EncodedAudio*) malloc(arr.dataCount * sizeof(EncodedAudio));
    
    for (int i = 0; i < arr.dataCount; i++) {
        EncodedAudio  encodedAudio  = {0};
        
        memcpy(&encodedAudio.dataLength, buffer->buffer + pointerPlase, sizeof(int));
        pointerPlase        += sizeof(int);
        encodedAudio.data   = (unsigned char*) malloc(encodedAudio.dataLength);
        
        memcpy(encodedAudio.data, buffer->buffer + pointerPlase, encodedAudio.dataLength);
        pointerPlase        += encodedAudio.dataLength;
        
        arr.data[i] = encodedAudio;
        
    }

    return arr;
}







