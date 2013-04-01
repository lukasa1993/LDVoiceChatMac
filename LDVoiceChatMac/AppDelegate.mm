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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.userListArray = [NSMutableArray array];
    self.usersMap      = [NSMutableDictionary dictionary];
    networkLayer       = [LDNetworkLayer networkLayer];
    userDefaults       = [NSUserDefaults standardUserDefaults];
    
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
        
        [self startVoiceComunication];
    }
    
}

// Netowork Callbacks  --------------------------------------------------

- (void)userList:(NSArray *)_userList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.userListArray count]) {
            [self.userListArray removeAllObjects];
            for (id key in self.usersMap) {
                [(self.usersMap)[key] stopUserVoiceThread];
                [self.usersMap removeObjectForKey:key];
            }
        }
        
        for (NSDictionary* user in _userList) { // creating separate audio input thread for each user
            (self.usersMap)[user[@"name"]] = [LDUserVoiceThread userVoiceThread];
            [self.userListArray addObject:user];
        }
        [userListColumn reloadData];
    });
}

- (void)incomingVoiceData:(NSString *)from voice:(NSData *)audio
{
    [(self.usersMap)[from] incomingVoice:audio];
}

// UI Callbacks ----------------------------------------------

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                            owner:self];
    @autoreleasepool {
        NSDictionary *user = userListArray[(NSUInteger) row];
        cellView.textField.stringValue = user[@"name"];
    }
    
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [userListArray count];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = [notification object];
    @autoreleasepool {
        NSString *userName = [textField stringValue];
        NSString *savedName = [userDefaults objectForKey:@"name"];
        [userDefaults setObject:userName forKey:@"name"];
        
        if (!savedName) {
            [networkLayer startCommunication];
            [self startVoiceComunication];
        } else {
            [networkLayer renameUser:savedName NewName:userName];
            [voiceRecording renameUser:userName];
        }
    }
}

- (IBAction)settingsChanged:(id)sender
{
    if ([[hostField stringValue] length] < 2) {
        [hostField becomeFirstResponder];
        return;
    } else if([portField integerValue] < 2000){
        [portField becomeFirstResponder];
        return;
    }
    
    if ([[hostField stringValue] isEqualToString:@"localhost"]) {
        [hostField setStringValue:@"127.0.0.1"];
    }
    
    @autoreleasepool {
        NSString *ip = [[NSHost hostWithName:[hostField stringValue]] address];
        [hostField setStringValue:ip];
    }
    [userDefaults setObject:[hostField stringValue] forKey:@"host"];
    [userDefaults setObject:[portField stringValue] forKey:@"port"];
    [settingsWindow setIsVisible:NO];
    
    if ([userDefaults objectForKey:@"name"]) {
        [networkLayer reconnect];
    }
}

- (IBAction)callSettings:(id)sender
{
    [settingsWindow setIsVisible:YES];
    [hostField setStringValue:[userDefaults objectForKey:@"host"]];
    [portField setStringValue:[userDefaults objectForKey:@"port"]];
    NSLog(@"%@", [userDefaults objectForKey:@"host"]);
}

// Voice Threads ----------------------------------------------

- (void)startVoiceComunication
{
    voiceRecording     = [LDVoiceRecordingThread recordingThreadWith:networkLayer with:[userDefaults objectForKey:@"name"]];
    [voiceRecording startRecordingThread];
}

- (void)stopVoiceComunication
{
    [voiceRecording stopRecordingThread];
}


@end

