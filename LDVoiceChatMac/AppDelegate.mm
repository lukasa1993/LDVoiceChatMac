//
//  AppDelegate.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"host"]) {
        [userDefaults setObject:@"localhost" forKey:@"host"];
    }
    
    if (![userDefaults objectForKey:@"port"]) {
        [userDefaults setObject:@"4444" forKey:@"port"];
    }
    
    eventManager = [LDEventManager eventManager];
}

@end
