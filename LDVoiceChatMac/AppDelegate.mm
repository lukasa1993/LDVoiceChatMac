//
//  AppDelegate.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize userListColumn;
@synthesize userNameField;
@synthesize hostField;
@synthesize portField;
@synthesize settingsButton;
@synthesize settingsWindow;
@synthesize settingsChangedButton;
@synthesize userListArray;
@synthesize usersMap;
@synthesize audioPlotView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.userListArray = [NSMutableArray array];
    self.usersMap      = [NSMutableDictionary dictionary];
    
    userDefaults       = [NSUserDefaults standardUserDefaults];
    networkLayer       = [LDNetworkLayer networkLayer];
    voiceRecording     = [LDVoiceRecordingThread recordingThreadWith:networkLayer];
    
    [networkLayer setDelegate:self];
    
    if (![userDefaults objectForKey:@"host"]) {
        [userDefaults setObject:@"127.0.0.1" forKey:@"host"];
    }
    
    if (![userDefaults objectForKey:@"port"]) {
        [userDefaults setObject:@"4444" forKey:@"port"];
    }
    
    if ([userDefaults objectForKey:@"name"]) {
        [userNameField setStringValue:[userDefaults objectForKey:@"name"]];
        [networkLayer startCommunication];
    }
    
    [self startVoiceComunication];
}

// Netowork Callbacks  --------------------------------------------------

- (void)userList:(NSArray *)_userList {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.userListArray count]) {
            [self.userListArray removeAllObjects];
            [self.usersMap removeAllObjects];
        }
        
        [self.userListArray addObjectsFromArray:_userList];
        for (NSDictionary* user in self.userListArray) { // creating separate audio input thread for each user
            [self.usersMap setObject:[LDUserVoiceThread userVoiceThread] forKey:[user objectForKey:@"name"]];
        }
        [userListColumn reloadData];
    });
}

- (void)incomingVoiceData:(NSString *)from voice:(NSData *)audio {
    [[self.usersMap objectForKey:from] incoingVoice:audio];
}

// UI Callbacks ----------------------------------------------

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                            owner:self];
    NSDictionary *user = [userListArray objectAtIndex:(NSUInteger) row];
    
    cellView.textField.stringValue = [user objectForKey:@"name"];
    
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [userListArray count];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSString *userName = [textField stringValue];
    NSString *savedName = [userDefaults objectForKey:@"name"];
    [userDefaults setObject:userName forKey:@"name"];
    
    if (!savedName) {
        [networkLayer startCommunication];
    } else {
        [networkLayer renameUser:savedName NewName:userName];
    }
}

- (IBAction)settingsChanged:(id)sender {
    if ([[hostField stringValue] isEqualToString:@"localhost"]) {
        [hostField setStringValue:@"127.0.0.1"];
    }
    
    NSString *ip = [[NSHost hostWithName:[hostField stringValue]] address];
    [hostField setStringValue:ip];
    
    [userDefaults setObject:[hostField stringValue] forKey:@"host"];
    [userDefaults setObject:[portField stringValue] forKey:@"port"];
    [settingsWindow setIsVisible:NO];
    
    if ([userDefaults objectForKey:@"name"]) {
        [networkLayer reconnect];
    }
}

- (IBAction)callSettings:(id)sender {
    [settingsWindow setIsVisible:YES];
    [hostField setStringValue:[userDefaults objectForKey:@"host"]];
    [portField setStringValue:[userDefaults objectForKey:@"port"]];
    NSLog(@"%@", [userDefaults objectForKey:@"host"]);
}

// Voice Threads ----------------------------------------------

- (void)startVoiceComunication
{
    [voiceRecording startRecordingThread];
}

- (void)stopVoiceComunication
{
    [voiceRecording stopRecordingThread];
}


@end

