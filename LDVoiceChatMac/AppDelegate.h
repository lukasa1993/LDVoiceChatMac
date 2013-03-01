//
//  AppDelegate.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LDNetworkLayer.h"
#import "LDAudioDefaults.h"
#import "LDTransportPreparation.c"
#import "LDAudioInput.c"
#import "LDAudioOutput.c"

@interface AppDelegate : NSViewController <NSApplicationDelegate, NSTextFieldDelegate,
NSTableViewDataSource, NSTableViewDelegate, LDNetworkDataProtocol>
{
    NSButton *settingsButton;
    NSButton *settingsChangedButton;
    NSWindow *settingsWindow;
    
    NSTextField *userNameField;
    NSTextField *hostField;
    NSTextField *portField;
    
    NSTableView *userListColumn;
    NSUserDefaults *userDefaults;
    
    NSMutableArray *userListArray;
    
    BOOL speaking;
    
    NSThread* speakingThread;
    
    LDNetworkLayer *networkLayer;
    
    AudioHandlerStruct *audioInputHandler;
    AudioHandlerStruct *audioOutputHandler;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *userNameField;
@property (assign) IBOutlet NSTextField *hostField;
@property (assign) IBOutlet NSTextField *portField;
@property (assign) IBOutlet NSButton *settingsButton;
@property (assign) IBOutlet NSButton *settingsChangedButton;
@property (assign) IBOutlet NSWindow *settingsWindow;
@property (assign) IBOutlet NSTableView *userListColumn;

@property (strong) NSMutableArray *userListArray;

- (IBAction)settingsChanged:(id)sender;
- (IBAction)callSettings:(id)sender;

@end
