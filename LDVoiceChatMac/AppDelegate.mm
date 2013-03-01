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

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    userDefaults       = [NSUserDefaults standardUserDefaults];
    self.userListArray = [NSMutableArray array];
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
    
    [self startSpeaking];
}


- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField* textField = [notification object];
    NSString* userName = [textField stringValue];
    NSString* savedName = [userDefaults objectForKey:@"name"];
    [userDefaults setObject:userName forKey:@"name"];
    
    if (!savedName) {
        [networkLayer startCommunication];
    } else {
        [networkLayer renameUser:savedName NewName:userName];
    }
}

- (IBAction)settingsChanged:(id)sender
{
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
    [self startSpeaking];
}

- (void)incomingVoiceData:(NSData *)data
{
    [[[NSThread alloc] initWithTarget:self selector:@selector(voiceThread:) object:[NSData dataWithData:data]] start];
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

- (void)initSpeakingThread
{
    if (!speakingThread || [speakingThread isCancelled]) {
        speakingThread = [[NSThread alloc] initWithTarget:self selector:@selector(speakingThread) object:nil];
    }
}

- (void)startSpeaking
{
    [self initSpeakingThread];
    speaking = YES;
    [speakingThread start];
}

- (void)stopSpeaking
{
    speaking = NO;
    [speakingThread cancel];
}

// Thread Work -------------------------------

- (void)speakingThread
{
    while (speaking) {
        EncodedAudioArr* audio     = LD_RecordAndEncodeAudio(audioInputHandler);
        LD_Buffer*       buffer    = EncodedAudioArrToBuffer(audio);
        NSMutableData*   finalData = [NSMutableData data];
        NSDictionary*    dict      = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"voice", @"action",
                                      [userDefaults objectForKey:@"name"], @"name",
                                      [NSNumber numberWithInt:buffer->bufferLength], @"audioDataLength",
                                      nil];
        
        [finalData appendData:[dict messagePack]];
        [finalData appendBytes:buffer->buffer length:buffer->bufferLength];
        
        free(buffer->buffer);
        free(buffer);
        [networkLayer sendNSDataToServer:finalData];
    }
}

- (void)voiceThread:(NSData*)audio
{
    LD_Buffer* buffer    = (LD_Buffer*) malloc(sizeof(LD_Buffer));
    buffer->buffer       = (unsigned char*)[audio bytes];
    buffer->bufferLength = (int) [audio length];
    EncodedAudioArr* arr = BufferToEncodedAudioArr(buffer);
    LD_DecodeAndPlayAudio(audioOutputHandler, arr);
}

@end
