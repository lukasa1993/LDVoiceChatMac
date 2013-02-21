//
//  LDEventManager.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/21/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDNetworkLayer.h"

@interface LDEventManager : NSObject<NSTextFieldDelegate>
{
    NSTextField *userNameField;
    NSTextField *hostField;
    NSTextField *portField;
    NSButton *settingsButton;
    NSButton *settingsChangedButton;
    NSWindow *settingsWindow;
    NSTableColumn *userList;
    NSUserDefaults *userDefaults;
    
    
    LDNetworkLayer *networkLayer;
}

@property (assign) IBOutlet NSTextField *userNameField;
@property (assign) IBOutlet NSTextField *hostField;
@property (assign) IBOutlet NSTextField *portField;
@property (assign) IBOutlet NSButton *settingsButton;
@property (assign) IBOutlet NSButton *settingsChangedButton;
@property (assign) IBOutlet NSWindow *settingsWindow;
@property (assign) IBOutlet NSTableColumn *userList;


+(id)eventManager;

- (IBAction)settingsChanged:(id)sender;
- (IBAction)callSettings:(id)sender;
- (IBAction)userMute;


@end
