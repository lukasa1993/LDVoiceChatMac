//
//  AppDelegate.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LDEventManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    LDEventManager* eventManager;
}

@property (assign) IBOutlet NSWindow *window;

@end
