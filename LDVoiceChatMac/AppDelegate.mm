//
//  AppDelegate.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize menubarController = _menubarController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.menubarController = [[PTMenubarController alloc] init];
    [self _setupPopover];
}

// -----------------------------------------------------------------------

- (void)_setupPopover
{
    if (!self.popover) {
        self.popover                       = [[NSPopover alloc] init];
        self.popover.contentViewController = [[PopoverController alloc] initWithNibName:@"PopoverController" bundle:nil];
        self.popover.contentSize           = (CGSize){370, 190};
        self.popover.appearance            = NSPopoverAppearanceHUD;
    }
    
    popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUp handler:^(NSEvent* event)
                                {
                                    [self closePopover];
                                }];
}

// -----------------------------------------------------------------------

#pragma mark - Actions

- (void)closePopover
{
    [NSEvent removeMonitor:popoverTransiencyMonitor];
    popoverTransiencyMonitor = nil;
    
    if(!self.active) return ;
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.active = !self.active;
    if (!self.active) {
        [self.popover performClose:self];
    }
}

// -----------------------------------------------------------------------

- (void)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    
    NSLog(@"Menulet clicked");
    
    self.active = ! self.active;
    if (self.active) {
        [self _setupPopover];
        [self.popover showRelativeToRect:[sender frame]
                                  ofView:sender
                           preferredEdge:NSMinYEdge];
    } else {
        [self.popover performClose:self];
    }
}



@end

