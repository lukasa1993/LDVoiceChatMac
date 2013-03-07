//
//  LDSineView.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/6/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDSineView.h"

@implementation LDSineView

- (void)setAudioData:(float*)buffer :(int)bufferLenth
{
    audioData = buffer;
    audioDataLength = bufferLenth;
}


- (void)drawRect:(NSRect)rect
{
    if (audioData == NULL) {
        return;
    }
    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(myContext, 1, 0, 0, 1);
    int width  = 10;
    for (int i = 0; i < audioDataLength; i++) {
        CGFloat sineY = (self.frame.size.height / 2) + (800 * audioData[i]);
        CGFloat sineX = width + (width * i);
        if (sineX > self.frame.size.width - width) {
            sineX -= self.frame.size.width;
//            CGContextClearRect(myContext, self.frame);
        }
        
        CGRect dotRect = CGRectMake (sineX, sineY, width, width);
        CGContextFillEllipseInRect(myContext, dotRect);
        CGContextStrokeEllipseInRect(myContext, dotRect);
        CGContextFlush(myContext);
    }
}

@end
