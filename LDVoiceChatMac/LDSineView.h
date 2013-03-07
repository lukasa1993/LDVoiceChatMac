//
//  LDSineView.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/6/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LDSineView : NSView
{
    float* audioData;
    int    audioDataLength;
}

- (void)setAudioData:(float*)buffer :(int)bufferLenth;

@end
