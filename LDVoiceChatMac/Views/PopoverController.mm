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

#import "PopoverController.h"

@implementation PopoverController
@synthesize userListArray = _userListArray;
@synthesize usersMap      = _usersMap;

// -----------------------------------------------------------------------

- (void) initialize{
    checkError(Pa_Initialize()); // Yeaaa
    
    userListArray      = [NSMutableArray array];
    usersMap           = [NSMutableDictionary dictionary];
    networkLayer       = [LDNetworkLayer networkLayer];
    userDefaults       = [NSUserDefaults standardUserDefaults];
    
    [networkLayer setDelegate:self];
    
    if (![userDefaults objectForKey:@"host"]) {
        [userDefaults setObject:@"127.0.0.1" forKey:@"host"];
    }
    
    if (![userDefaults objectForKey:@"port"]) {
        [userDefaults setObject:@"4444" forKey:@"port"];
    }
    
    if ([userDefaults objectForKey:@"name"] && [userDefaults objectForKey:@"channel"]) {
        [networkLayer startCommunication];
        [self startVoiceComunication];
    }
    
}

// -----------------------------------------------------------------------

- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

// -----------------------------------------------------------------------

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

// -----------------------------------------------------------------------

- (void)awakeFromNib {
    NSLog(@"Awake");
    
    if ([userDefaults objectForKey:@"name"]) {
        [userNameField setStringValue:[userDefaults objectForKey:@"name"]];
    }
    
    if ([userDefaults objectForKey:@"channel"]) {
        [channelField setStringValue:[userDefaults objectForKey:@"channel"]];
    }
    
    [speakButton setDelegate:self];
}

// UI Callbacks ----------------------------------------------------------

- (void)mouseDown
{
    NSLog(@"Mouse Down");
    [voiceRecording isMute] ? [voiceRecording unMute] : [voiceRecording mute];
}

- (void)mouseUp
{
    NSLog(@"Mouse Up");
    [voiceRecording isMute] ? [voiceRecording unMute] : [voiceRecording mute];
}

- (IBAction)speakingLockButton:(id)sender
{
    [voiceRecording isMute] ? [voiceRecording unMute] : [voiceRecording mute];
}

// -----------------------------------------------------------------------

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                            owner:self];
    @autoreleasepool {
        if ([userListArray count]) {
            NSDictionary *user = userListArray[(NSUInteger) row];
            cellView.textField.stringValue = user[@"name"];
        }
    }
    
    return cellView;
}

// -----------------------------------------------------------------------

- (IBAction)columnChangeSelected:(id)sender
{
    NSTableView *tableView  = sender;
    NSInteger clickedRow    = [tableView clickedRow];
    NSInteger clickedColumn = [tableView clickedColumn];
    
    if (clickedRow > -1 && clickedColumn > -1) {
        NSTableCellView   *cellView = [tableView viewAtColumn:clickedColumn row:clickedRow makeIfNecessary:NO];
        if (cellView) {
            NSString          *userName = [[cellView textField] stringValue];
            LDUserVoiceThread *user     = (usersMap)[userName];
            
            [user isUserSpeaking] ? [networkLayer muteUser:userName] : [networkLayer UnMuteUser:userName];
            [user isUserSpeaking] ? [user stopUserVoiceThread]       : [user startUserVoiceThread];
        }
    }
}

// -----------------------------------------------------------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [userListArray count];
}

// -----------------------------------------------------------------------

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = [notification object];
    @autoreleasepool {
        NSString *text  = [textField stringValue];
        NSString *savedName = [userDefaults objectForKey:@"name"];
        NSString *channel   = [userDefaults objectForKey:@"channel"];
        
        if(textField.tag == 100) {
            [userDefaults setObject:text forKey:@"channel"];
            if (!savedName && !channel) {
                [networkLayer startCommunication];
                [self startVoiceComunication];
            } else {
                [networkLayer renameUser:savedName NewName:text];
            }
        } else if (textField.tag == 200) {
            [userDefaults setObject:text forKey:@"name"];
            [networkLayer reconnect];
        }
        [voiceRecording notifyChanges];
    }
}

// -----------------------------------------------------------------------

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

// -----------------------------------------------------------------------

- (IBAction)callSettings:(id)sender
{
    [settingsWindow setIsVisible:YES];
    [hostField setStringValue:[userDefaults objectForKey:@"host"]];
    [portField setStringValue:[userDefaults objectForKey:@"port"]];
}

// Netowork Callbacks  --------------------------------------------------

- (void)userList:(NSArray *)_userList
{
    if ([userListArray count]) {
        for (id key in usersMap) {
            [(usersMap)[key] stopUserVoiceThread];
        }
        [userListArray removeAllObjects];
        [usersMap removeAllObjects];
    }
    for (NSDictionary* user in _userList) { // creating separate audio input thread for each user
        LDUserVoiceThread *userObjcect = [LDUserVoiceThread userVoiceThread];
        [user[@"muted"] intValue] ? [userObjcect stopUserVoiceThread] : [userObjcect startUserVoiceThread];
        (usersMap)[user[@"name"]]      = userObjcect;
        
        [userListArray addObject:user];
    }
    
    [userListColumn reloadData];
}

// -----------------------------------------------------------------------

- (void)incomingVoiceData:(NSString *)from voice:(NSData *)audio
{
    [(usersMap)[from] incomingVoice:audio];
}

// Voice Threads ----------------------------------------------

- (void)startVoiceComunication
{
    if (voiceRecording == nil) {
        voiceRecording = [LDVoiceRecordingThread recordingThreadWith:networkLayer];
    }
    [voiceRecording startRecordingThread];
}

// -----------------------------------------------------------------------

- (void)stopVoiceComunication
{
    [voiceRecording stopRecordingThread];
}

// -----------------------------------------------------------------------

@end
