//
//  AppDelegate.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PTMenubarController.h"
#import "PopoverController.h"

@interface AppDelegate : NSViewController <NSApplicationDelegate>
{
    id popoverTransiencyMonitor;
}

@property (nonatomic, strong) PTMenubarController *menubarController;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSPopover *popover;

@end
