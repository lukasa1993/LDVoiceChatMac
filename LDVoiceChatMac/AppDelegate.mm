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
@synthesize sineView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    userDefaults       = [NSUserDefaults standardUserDefaults];
    self.userListArray = [NSMutableArray array];
    self.incomingVoice = [NSMutableArray array];
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

- (void)incomingVoiceData:(NSData *)data
{
    //    [[[NSThread alloc] initWithTarget:self selector:@selector(voiceThread:) object:[NSData dataWithData:data]] start];
    //    [self voiceThread:data];
    [incomingVoice addObject:data];
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
    [NSThread detachNewThreadSelector:@selector(speakingThread) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(voiceThread)    toTarget:self withObject:nil];
}

- (void)stopVoiceComunication
{
    speaking = NO;
    LD_StopRecordingStream(audioInputHandler);
    LD_StopPlayebackStream(audioOutputHandler);
}

// Thread Work -------------------------------

- (void)speakingThread
{
    RawAudioData*  data;
    RawAudioData*  pData;
    LD_Buffer      buffer;
    NSMutableData* finalData;
    NSDictionary*  dict;
    
    while (speaking) {
        pData   = audioInputHandler->userData;
        ring_buffer_size_t elementsInBuffer = PaUtil_GetRingBufferReadAvailable(&pData->ringBuffer);
        if (elementsInBuffer >= pData->ringBuffer.bufferSize / SENDER_DIVIZION)
        {
            data                            = initRawAudioData();
            int pointerPosition             = 0;
            void* ptr[2]                    = {0};
            ring_buffer_size_t sizes[2]     = {0};
            ring_buffer_size_t elementsRead = PaUtil_GetRingBufferReadRegions(&pData->ringBuffer, elementsInBuffer,
                                                                              ptr + 0, sizes + 0, ptr + 1, sizes + 1);
            
            if (elementsRead > 0)
            {
                for (int i = 0; i < 2 && ptr[i] != NULL; ++i)
                {
                    memcpy(data->audioArray + pointerPosition, ptr[i], pData->ringBuffer.elementSizeBytes * sizes[i]);
                    pointerPosition += sizes[i];
                }
                PaUtil_AdvanceRingBufferReadIndex(&pData->ringBuffer, elementsRead);
            }
            
            [sineView setAudioData:data->audioArray :(SAMPLE_RATE * SECONDS * CHANELS) / FRAMES];
            [sineView setNeedsDisplay:NO];
            [sineView setNeedsDisplay:YES];
            
            
            buffer    = EncodedAudioArrToBuffer(encodeAudio(data));
            finalData = [NSMutableData data];
            dict      = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"voice", @"action",
                         [userDefaults objectForKey:@"name"], @"name",
                         [NSNumber numberWithInt:buffer.bufferLength], @"audioDataLength",
                         nil];
            
            [finalData appendData:[dict messagePack]];
            [finalData appendBytes:buffer.buffer length:buffer.bufferLength];
            
            [networkLayer sendNSDataToServer:finalData];
            
            free(buffer.buffer);
        }
    }
}

- (void)voiceThread
{
    while (speaking) {
        if ([incomingVoice count] == 0) {
            wait(0.2f);
            continue;
        }
        NSData* audio         = [incomingVoice objectAtIndex:0];
        LD_Buffer buffer      = {0};
        buffer.buffer         = (unsigned char*)[audio bytes];
        buffer.bufferLength   = (int) [audio length];
        EncodedAudioArr arr   = BufferToEncodedAudioArr(&buffer);
        RawAudioData* pData   = audioOutputHandler->userData;
        RawAudioData* data    = decodeAudio(audioOutputHandler, arr);
        
        
        ring_buffer_size_t elementsInBuffer = PaUtil_GetRingBufferWriteAvailable(&pData->ringBuffer);
        
        if (elementsInBuffer >= pData->ringBuffer.bufferSize / RECEIVER_DIVIZION)
        {
            void* ptr[2] = {0};
            ring_buffer_size_t sizes[2] = {0};
            
            PaUtil_GetRingBufferWriteRegions(&pData->ringBuffer, elementsInBuffer, ptr + 0, sizes + 0, ptr + 1, sizes + 1);
            
            ring_buffer_size_t itemsReadFromFile = 0;
            for (int i = 0; i < 2 && ptr[i] != NULL; ++i)
            {
                memcpy(ptr[i], data->audioArray  + itemsReadFromFile, pData->ringBuffer.elementSizeBytes * sizes[i]);
                itemsReadFromFile += sizes[i];
            }
            PaUtil_AdvanceRingBufferWriteIndex(&pData->ringBuffer, itemsReadFromFile);
        }
        
        free(data->audioArray);
        [incomingVoice removeObject:audio];
    }
    
}

@end

