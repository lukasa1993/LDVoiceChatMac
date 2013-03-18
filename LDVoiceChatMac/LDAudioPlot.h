//
//  LDAudioPlot.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 3/12/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LittlePlotLabelView.h"
#import "LittlePlotTableView.h"
#import "LittlePlotBarView.h"
// Name Space correct
#import "LPPieChartView.h"
#import "LPLineChartView.h"
// 3D
#import "LP3DBarChartView.h"
#import "LP3DPieChartView.h"

@interface LDAudioPlot : NSView
{
    NSBezierPath    *path;
    NSMutableArray  *audioData;
    NSInteger        prevX;
    LPLineChartView *lineView;
}

- (void)addAudio:(void*)data length:(NSInteger)len;

@end
