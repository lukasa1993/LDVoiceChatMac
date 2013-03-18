//
//  LDAudioPlot.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/12/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDAudioPlot.h"
@implementation LDAudioPlot

- (void)addAudio:(void*)data length:(NSInteger)len
{
    if (audioData == nil) {
        path      = [NSBezierPath bezierPath];
        audioData = [NSMutableArray array];
        prevX     = 0;
        lineView  = [[LPLineChartView alloc]initWithFrame:[_window frame]];
        [_window setContentView:lineView];
        [path moveToPoint:NSMakePoint(0, 0)];
        [lineView setPlotColour:[NSColor cyanColor]];
    }
    
    
    [audioData removeAllObjects];
    
    float* samples = (float*) data;
    for (int i = 0; i < len / sizeof(float); i+=10) {
        [audioData addObject:[NSNumber numberWithInt:(NSInteger)(samples[i] * 1000) % 100]];
    }
    
    [lineView setPoints:audioData];
    [lineView drawPoints];
    [lineView display];
}

@end
