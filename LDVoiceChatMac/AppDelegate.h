//
//  AppDelegate.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LDNetworkLayer.h"
#import "LDUserVoiceThread.h"
#import "LDVoiceRecordingThread.h"

@interface AppDelegate : NSViewController <NSApplicationDelegate, NSTextFieldDelegate,
NSTableViewDataSource, NSTableViewDelegate, LDNetworkDataProtocol> {
    NSButton *settingsButton;
    NSButton *settingsChangedButton;
    NSWindow *settingsWindow;
    
    NSTextField *userNameField;
    NSTextField *hostField;
    NSTextField *portField;
    
    NSTableView *userListColumn;
    NSUserDefaults *userDefaults;
        
    NSMutableDictionary    *usersMap;
    NSMutableArray         *userListArray;
    LDNetworkLayer         *networkLayer;
    LDVoiceRecordingThread *voiceRecording;
}

@property(strong) IBOutlet NSWindow *window;
@property(strong) IBOutlet NSTextField *userNameField;
@property(strong) IBOutlet NSTextField *hostField;
@property(strong) IBOutlet NSTextField *portField;
@property(strong) IBOutlet NSButton *settingsButton;
@property(strong) IBOutlet NSButton *settingsChangedButton;
@property(strong) IBOutlet NSWindow *settingsWindow;
@property(strong) IBOutlet NSTableView *userListColumn;

@property(strong) NSMutableArray      *userListArray;
@property(strong) NSMutableDictionary *usersMap;

- (IBAction)settingsChanged:(id)sender;
- (IBAction)callSettings:(id)sender;

@end
