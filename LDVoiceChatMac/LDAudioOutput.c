//
//  LDAudioOutput.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/28/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioDefaults.h"

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


