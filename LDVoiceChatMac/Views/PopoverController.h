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

#import <Cocoa/Cocoa.h>

#import "LDNetworkLayer.h"
#import "LDUserVoiceThread.h"
#import "LDVoiceRecordingThread.h"
#import "LDCustomeButton.h"
#import "LDDeviceChangedProtocol.h"

@interface PopoverController : NSViewController <NSPopoverDelegate, NSTextFieldDelegate,
NSTableViewDataSource, NSTableViewDelegate, LDNetworkDataProtocol, LDCustomeButtonEvents, LDDeviceChangedProtocol>
{
    IBOutlet NSImageView   *imageView;
    
    /* Status info */
    IBOutlet NSTextField   *textFieldStatusInfo;
    
    NSUserDefaults         *userDefaults;
    NSMutableDictionary    *usersMap;
    NSMutableArray         *userListArray;
    
    NSLock                 *deviceChangedLock;
    
    LDVoiceRecordingThread *voiceRecording;
    LDNetworkLayer         *networkLayer;
    
    IBOutlet LDCustomeButton *speakButton;
    IBOutlet LDCustomeButton *lockSpeaking;
    
    IBOutlet NSTextField *userNameField;
    IBOutlet NSTextField *channelField;
    IBOutlet NSTextField *hostField;
    IBOutlet NSTextField *portField;
    IBOutlet NSButton    *settingsChangedButton;
    IBOutlet NSWindow    *settingsWindow;
    IBOutlet NSTableView *userListColumn;
    IBOutlet NSView      *statusView;
}

- (IBAction)columnChangeSelected:(id)sender;
- (void)applicationWillTerminate;

@property (nonatomic, assign) BOOL hasActivePanel;
@property (nonatomic, strong) NSWindow               *controllerWindow;
@property (nonatomic, weak)   NSMutableDictionary    *usersMap;
@property (nonatomic, weak)   NSMutableArray         *userListArray;

@end
