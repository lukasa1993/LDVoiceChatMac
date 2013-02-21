//
//  LDEventManager.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/21/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDEventManager.h"

@implementation LDEventManager
@synthesize userList;
@synthesize userNameField;
@synthesize hostField;
@synthesize portField;
@synthesize settingsButton;
@synthesize settingsWindow;
@synthesize settingsChangedButton;

+(id)eventManager
{
    return [[self alloc] init];
}

-(id)init
{
    if (self = [super init]) {
        networkLayer = [LDNetworkLayer networkLayer];
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

-(void)awakeFromNib
{
    [userNameField setDelegate:self];
    if ([userDefaults objectForKey:@"name"]) {
        [userNameField setStringValue:[userDefaults objectForKey:@"name"]];
        [networkLayer startCommunication];
    }
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

- (IBAction)userMute
{
    
}

@end
