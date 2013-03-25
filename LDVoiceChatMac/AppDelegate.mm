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
@synthesize incomingVoice;
@synthesize audioPlotView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    userDefaults       = [NSUserDefaults standardUserDefaults];
    self.userListArray = [NSMutableArray array];
    self.incomingVoice = [NSMutableArray array];
    finalData          = [NSMutableData dataWithCapacity:MAX_BUFF];;
    networkLayer       = [LDNetworkLayer networkLayer];
    
    audioInputHandler  = LD_InitAudioInputHandler();
    audioOutputHandler = LD_InitAudioOutputHandler();
    
    [networkLayer setDelegate:self];
    
    if (![userDefaults objectForKey:@"host"]) {
        [userDefaults setObject:@"localhost" forKey:@"host"];
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


- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField* textField = [notification object];
    NSString*    userName  = [textField stringValue];
    NSString*    savedName = [userDefaults objectForKey:@"name"];
    [userDefaults setObject:userName forKey:@"name"];
    
    if (!savedName) {
        [networkLayer startCommunication];
    } else {
        [networkLayer renameUser:savedName NewName:userName];
    }
}

- (IBAction)settingsChanged:(id)sender
{
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

- (IBAction)callSettings:(id)sender
{
    [settingsWindow setIsVisible:YES];
    [hostField setStringValue:[userDefaults objectForKey:@"host"]];
    [portField setStringValue:[userDefaults objectForKey:@"port"]];
    NSLog(@"%@",[userDefaults objectForKey:@"host"]);
}

// Netowork Callbacks  --------------------------------------------------

- (void)userList:(NSArray*)_userList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.userListArray count]) {
            [self.userListArray removeAllObjects];
        }
        
        [self.userListArray addObjectsFromArray:_userList];
        [userListColumn reloadData];
    });
}

- (void)communicationStarted
{
    //    [self startVoiceComunication];
}

-(void)incomingVoiceData:(NSString*)from voice:(NSData*)audio
{
    [incomingVoice addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              from, @"from",
                              audio, @"audio", nil]];
}

// Netowork Callbacks  End ----------------------------------------------

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn
                 row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                            owner:self];
    NSDictionary* user = [userListArray objectAtIndex:row];
    
    cellView.textField.stringValue = [user objectForKey:@"name"];
    
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [userListArray count];
}


- (void)startVoiceComunication
{
    speaking = YES;
    LD_StartRecordingStream(audioInputHandler);
    LD_StartPlayebackStream(audioOutputHandler);
    
    [NSThread detachNewThreadSelector:@selector(recorderLoop) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(playbackLoop) toTarget:self withObject:nil];
}

- (void)stopVoiceComunication
{
    speaking = NO;
    LD_StopRecordingStream(audioInputHandler);
    LD_StopPlayebackStream(audioOutputHandler);
}

// Thread Work -------------------------------

- (void)recorderLoop
{
    while (speaking) {
        [self encodeAndSend];
    }
}

- (void)encodeAndSend
{
    wait(SECONDS_TO_WAIT);
    LD_Buffer      buffer     = EncodedAudioArrToBuffer(encodeAudio(audioInputHandler->userData));
    NSDictionary*  dict       = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"voice", @"action",
                                 [userDefaults objectForKey:@"name"], @"name",
                                 [NSNumber numberWithInt:buffer.bufferLength], @"audioDataLength",
                                 nil];
    NSData*        dictPacked = [dict messagePack];
    
    [finalData replaceBytesInRange:NSMakeRange(0, [dictPacked length]) withBytes:[dictPacked bytes]];
    [finalData replaceBytesInRange:NSMakeRange([dictPacked length], buffer.bufferLength) withBytes:buffer.buffer];
    free(buffer.buffer);
    
    [networkLayer sendNSDataToServer:finalData];
    memset(audioInputHandler->userData->audioArray, 0, audioInputHandler->userData->audioArrayCurrentIndex * sizeof(float));
    audioInputHandler->userData->audioArrayCurrentIndex = 0;
}

-(void)playbackLoop
{
    while (speaking) {
        [self decodeAndPlay];
    }
}

- (void)decodeAndPlay
{
    RawAudioData* data           = audioOutputHandler->userData;
    data->audioArrayCurrentIndex = 0;
    memset(data->audioArray, 0, data->audioArrayByteLength);
    
    if ([incomingVoice count] > 0) {
        NSDictionary* incAudioDict = [incomingVoice objectAtIndex:0];
        NSData* audio              = [incAudioDict objectForKey:@"audio"];
        LD_Buffer buffer           = {0};
        buffer.buffer              = (unsigned char*)[audio bytes];
        buffer.bufferLength        = (int) [audio length];
        EncodedAudioArr arr        = BufferToEncodedAudioArr(&buffer);
        RawAudioData*  aData       = decodeAudio(audioOutputHandler, arr);
        
        memcpy(data->audioArray, aData->audioArray, aData->audioArrayByteLength);
        [audioPlotView addAudio:aData->audioArray length:aData->audioArrayLength];
        free(aData->audioArray);
        free(aData);
        
        [incomingVoice removeObjectAtIndex:0];
    } else {
        memset(data->audioArray, 0, data->audioArrayByteLength);
    }
    
    wait(SECONDS_TO_WAIT);
}

@end

