/*
 * Copyright (c) 2012. Picktek LLC. All Rights Reserved.
 * Licensed under the terms of the MIT License.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "PTStatusItemView.h"

@implementation PTStatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize activityImage = _activityImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize isActivity = _isActivity;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -

// -----------------------------------------------------------------------

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth  = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect    = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self               = [super initWithFrame:itemRect];

    if (self != nil) {
        _statusItem      = statusItem;
        _statusItem.view = self;
    }
    
    return self;
}

// -----------------------------------------------------------------------

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    NSImage *icon = nil;
    
    if(_isActivity) {
        icon = self.activityImage;
    } else {
        icon = self.isHighlighted ? self.alternateImage : self.image;
    }
    
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);

	[icon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

// -----------------------------------------------------------------------

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"Mouse Down StatusItem");
    [NSApp sendAction:self.action to:self.target from:self];
}

// -----------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

- (void)setActivity:(BOOL)newFlag
{
    if (_isActivity == newFlag) return;
    _isActivity = newFlag;
    [self setNeedsDisplay:YES];
}

// -----------------------------------------------------------------------

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

// -----------------------------------------------------------------------

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

// -----------------------------------------------------------------------

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

// -----------------------------------------------------------------------

- (void)setActivityImage:(NSImage *)newImage
{
    if (_activityImage != newImage) {
        _activityImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

// -----------------------------------------------------------------------

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

// -----------------------------------------------------------------------

@end
