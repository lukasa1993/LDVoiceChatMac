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
        [delegate mouseDown:self];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (delegate) {
        [delegate mouseUp:self];
    }
}

- (void)setState:(NSInteger)value
{
    NSImage* tmpImage = [self image];
    [self setImage:[self alternateImage]];
    [self setAlternateImage:tmpImage];
}

@end
