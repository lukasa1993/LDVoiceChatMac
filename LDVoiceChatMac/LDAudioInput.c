//
//  LDAudioInput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioDefaults.h"

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
