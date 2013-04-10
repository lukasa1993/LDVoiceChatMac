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

#import "AppDelegate.h"
#import "PopoverController.h"
#import <CoreAudio/CoreAudio.h>

@implementation AppDelegate
@synthesize menubarController = _menubarController;


static OSStatus AHPropertyListenerProc(AudioObjectID                       inObjectID,
                                       UInt32                              inNumberAddresses,
                                       const AudioObjectPropertyAddress    inAddresses[],
                                       void*                               inClientData)
{
    id delegate = CFBridgingRelease(inClientData);
    [delegate deviceChanged];
	return noErr;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.menubarController = [[PTMenubarController alloc] init];
    [self _setupPopover];
    [[NSApplication sharedApplication] deactivate];

	AudioObjectPropertyAddress prop = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };

    AudioObjectAddPropertyListener(kAudioObjectSystemObject, &prop, AHPropertyListenerProc, (void*)CFBridgingRetain(deviceChangedDelegate));
    
    AudioObjectPropertyAddress prop1 = {
        kAudioHardwarePropertyDefaultInputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    
    AudioObjectAddPropertyListener(kAudioObjectSystemObject, &prop1, AHPropertyListenerProc, (void*)CFBridgingRetain(deviceChangedDelegate));
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    PopoverController* popOver = (PopoverController*) self.popover.contentViewController;
    [popOver applicationWillTerminate];
}

// -----------------------------------------------------------------------

- (void)_setupPopover
{
    if (!self.popover) {
        PopoverController* popOver         = [[PopoverController alloc] initWithNibName:@"PopoverController" bundle:nil];
        deviceChangedDelegate              = popOver;
        self.popover                       = [[NSPopover alloc] init];
        self.popover.appearance            = NSPopoverAppearanceHUD;
        self.popover.contentViewController = popOver;
        self.popover.contentSize           = (CGSize){382, 204};
        popOver.controllerWindow           = self.menubarController.statusItem.view.window;
        
        [self.popover setDelegate:popOver];
    }
    
}

// -----------------------------------------------------------------------

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self closePopover];
}

// -----------------------------------------------------------------------

#pragma mark - Actions

- (void)togglePanel:(id)sender
{
    if (!self.active) {
        [self openPopover:sender];
    } else {
        [self closePopover];
    }
}

// -----------------------------------------------------------------------

- (void)openPopover:(id)sender
{
    [self _setupPopover];
    [self.popover showRelativeToRect:[sender frame]
                              ofView:sender
                       preferredEdge:NSMinYEdge];
    
    self.menubarController.hasActiveIcon = YES;
    self.active = YES;
    
    [self.menubarController.statusItem.view.window becomeKeyWindow];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

// -----------------------------------------------------------------------

- (void)closePopover
{
    [self.popover performClose:self];
    
    self.menubarController.hasActiveIcon = NO;
    self.active = NO;
    
    [self.menubarController.statusItem.view.window resignKeyWindow];
    [[NSApplication sharedApplication] deactivate];
}

// -----------------------------------------------------------------------


@end
