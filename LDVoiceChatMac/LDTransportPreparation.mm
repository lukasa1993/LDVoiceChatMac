//
//  LDTransportPreparation.c
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/27/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDTransportPreparation.h"

LD_Buffer EncodedAudioArrToBuffer(EncodedAudioArr encodedData) {
    int pointerPlase = 0;
    LD_Buffer bufferStruct = {0};
    bufferStruct.bufferLength = encodedData.dataLength + (sizeof(int) * (encodedData.dataCount + 1)); // + 1 for
    bufferStruct.buffer = (unsigned char *) calloc((size_t) bufferStruct.bufferLength, sizeof(unsigned char));

    memcpy(bufferStruct.buffer + pointerPlase, &encodedData.dataCount, sizeof(int)); // this
    pointerPlase += sizeof(int);

    for (int i = 0; i < encodedData.dataCount; i++) {
        EncodedAudio *encodedAudio = &encodedData.data[i];
        unsigned char *encodedAudioData = encodedAudio->data;
        int encodedAudioDataLength = encodedAudio->dataLength;

        memcpy(bufferStruct.buffer + pointerPlase, &encodedAudioDataLength, sizeof(int));
        pointerPlase += sizeof(int);

        memcpy(bufferStruct.buffer + pointerPlase, encodedAudioData, (size_t) encodedAudioDataLength);
        pointerPlase += encodedAudioDataLength;

        free(encodedAudioData);
    }

    free(encodedData.data);
    return bufferStruct;
}

EncodedAudioArr BufferToEncodedAudioArr(LD_Buffer *buffer) {
    EncodedAudioArr arr = {0};
    int pointerPlase = 0;

    memcpy(&arr.dataCount, buffer->buffer + pointerPlase, sizeof(int));
    pointerPlase += sizeof(int);

    if (arr.dataCount > 200 || arr.dataCount < 0) {
        printf("Corrupted Top Segment \n");
        arr.dataLength = -1;
        return arr;
    }

    arr.dataLength = buffer->bufferLength - (sizeof(int) * (arr.dataCount + 1));
    arr.data = (EncodedAudio *) malloc((size_t) (arr.dataCount * sizeof(EncodedAudio)));

    for (int i = 0; i < arr.dataCount; i++) {
        EncodedAudio *encodedAudio = &arr.data[i];

        memcpy(&encodedAudio->dataLength, buffer->buffer + pointerPlase, sizeof(int));
        pointerPlase += sizeof(int);

        if (encodedAudio->dataLength > 200 || encodedAudio->dataLength < 0) {
            printf("Corrupted Segment \n");
            arr.dataLength = -1;
            break;
        }

        encodedAudio->data = (unsigned char *) calloc((size_t) encodedAudio->dataLength, sizeof(unsigned char));
        memcpy(encodedAudio->data, buffer->buffer + pointerPlase, (size_t) encodedAudio->dataLength);
        pointerPlase += encodedAudio->dataLength;
    }

    return arr;
}







