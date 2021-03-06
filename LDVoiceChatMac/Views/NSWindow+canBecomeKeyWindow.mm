//
//  NSWindow+canBecomeKeyWindow.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 4/8/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "NSWindow+canBecomeKeyWindow.h"
#import "AppDelegate.h"

@implementation NSWindow (canBecomeKeyWindow)

//This is to fix a bug with 10.7 where an NSPopover with a text field cannot be edited if its parent window won't become key
//The pragma statements disable the corresponding warning for overriding an already-implemented method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)canBecomeKeyWindow
{
    return [(AppDelegate*) [[NSApplication sharedApplication] delegate] active];
}
#pragma clang diagnostic pop

@end
