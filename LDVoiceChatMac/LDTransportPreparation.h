//
//  LDTransportPreparation.c
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/27/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#ifndef LDTransportPreparation_h
#define LDTransportPreparation_h

#include <string.h>
#include <stdio.h>
#import "LDAudioDefaults.h"

typedef struct {
    unsigned char *buffer;
    int bufferLength;
} LD_Buffer;

LD_Buffer EncodedAudioArrToBuffer(EncodedAudioArr encodedData);

EncodedAudioArr BufferToEncodedAudioArr(LD_Buffer *buffer);

#endif



