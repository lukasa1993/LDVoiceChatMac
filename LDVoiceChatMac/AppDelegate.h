//
//  AppDelegate.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LDNetworkLayer.h"
#import "LDAudioPlot.h"
#import "LDUserVoiceThread.h"
#import "LDVoiceRecordingThread.h"

@interface AppDelegate : NSViewController <NSApplicationDelegate, NSTextFieldDelegate,
NSTableViewDataSource, NSTableViewDelegate, LDNetworkDataProtocol> {
    __weak NSButton *settingsButton;
    __weak NSButton *settingsChangedButton;
    __weak NSWindow *settingsWindow;
    
    __weak NSTextField *userNameField;
    __weak NSTextField *hostField;
    __weak NSTextField *portField;
    
    __weak NSTableView *userListColumn;
    __weak NSUserDefaults *userDefaults;
    
    __weak LDAudioPlot *audioPlotView;
    
    NSMutableDictionary    *usersMap;
    NSMutableArray         *userListArray;
    LDNetworkLayer         *networkLayer;
    LDVoiceRecordingThread *voiceRecording;
}

@property(weak) IBOutlet NSWindow *window;
@property(weak) IBOutlet NSTextField *userNameField;
@property(weak) IBOutlet NSTextField *hostField;
@property(weak) IBOutlet NSTextField *portField;
@property(weak) IBOutlet NSButton *settingsButton;
@property(weak) IBOutlet NSButton *settingsChangedButton;
@property(weak) IBOutlet NSWindow *settingsWindow;
@property(weak) IBOutlet NSTableView *userListColumn;
@property(weak) IBOutlet LDAudioPlot *audioPlotView;

@property(strong) NSMutableArray      *userListArray;
@property(strong) NSMutableDictionary *usersMap;

- (IBAction)settingsChanged:(id)sender;
- (IBAction)callSettings:(id)sender;

@end
