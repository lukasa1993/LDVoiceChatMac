//
//  AppDelegate.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTMenubarController.h"
#import "LDDeviceChangedProtocol.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    PTMenubarController *menubarController;
    id popoverTransiencyMonitor;
    id<LDDeviceChangedProtocol> deviceChangedDelegate;
}


@property (nonatomic, strong) PTMenubarController *menubarController;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSPopover *popover;
@property (assign) IBOutlet NSWindow *window;
@end
