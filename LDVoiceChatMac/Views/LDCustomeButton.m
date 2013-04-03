//
//  LDCustomeButton.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 4/2/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDCustomeButton.h"

@implementation LDCustomeButton
@synthesize delegate;

- (void)mouseDown:(NSEvent *)theEvent
{
    if (delegate) {
        [delegate mouseDown];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (delegate) {
        [delegate mouseUp];
    }
}

@end
