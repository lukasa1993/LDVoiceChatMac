//
//  LDNetworkLayer.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/21/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDNetworkLayer.h"

@implementation LDNetworkLayer
@synthesize delegate;

+ (id)networkLayer
{
    return [[LDNetworkLayer alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        if (!InitializeSockets()) {
            NSLog(@"failed to initialize sockets");
        }
        
        if (!socket.Open(0)) {
            NSLog(@"failed to create socket!");
        }
        userDefaults = [NSUserDefaults standardUserDefaults];
        host = [userDefaults objectForKey:@"host"];
        port = [[userDefaults objectForKey:@"port"] intValue];
        buffer = malloc(MAX_BUFF);
    }
    
    return self;
}

- (Address)targetAddress
{
    @autoreleasepool {
        NSArray *hostArr = [host componentsSeparatedByString:@"."];
        return Address([hostArr[0] intValue], [hostArr[1] intValue], [hostArr[2] intValue], [hostArr[3] intValue], port);
    }
}

- (void)startCommunication
{
    NSLog(@"Start Communication");
    
    listeningToServer         = YES;
    NSDictionary *messageDict = @{@"action"  : @"init",
                                  @"name"    : [userDefaults objectForKey:@"name"],
                                  @"channel" : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    
    [self sendData:[data bytes] length:[data length]];
    [self startListeningToServer];
}

- (void)stopCommunication
{
    NSLog(@"Stop Communication");
    
    NSDictionary *messageDict = @{@"action"  : @"disc",
                                  @"name"    : [userDefaults objectForKey:@"name"],
                                  @"channel" : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    
    [self sendData:[data bytes] length:[data length]];
    [self stopListeningToServer];
}

- (void)muteUser:(NSString *)userName
{
    NSDictionary *messageDict = @{@"action"  : @"mute",
                                  @"villain" : userName,
                                  @"name"    : [userDefaults objectForKey:@"name"],
                                  @"channel" : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    
    [self sendData:[data bytes] length:[data length]];
}

- (void)UnMuteUser:(NSString *)userName
{
    NSDictionary *messageDict = @{@"action"  : @"unmute",
                                  @"villain" : userName,
                                  @"name"    : [userDefaults objectForKey:@"name"],
                                  @"channel" : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    
    [self sendData:[data bytes] length:[data length]];
}

- (void)renameUser:(NSString *)oldName NewName:(NSString *)newName
{
    NSDictionary *messageDict = @{@"action"      : @"rename",
                                  @"name"        : oldName,
                                  @"currentName" : newName,
                                  @"channel"     : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    
    [self sendData:[data bytes] length:[data length]];
}

- (void)switchChannel:(NSString *)channel
{
    NSDictionary *messageDict = @{@"action"         : @"switchchannel",
                                  @"currentchannel" : channel,
                                  @"name"           : [userDefaults objectForKey:@"name"] ,
                                  @"channel"        : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    
    [self sendData:[data bytes] length:[data length]];
}

- (void)reconnect
{
    host = [userDefaults objectForKey:@"host"];
    port = [[userDefaults objectForKey:@"port"] intValue];
    
    NSDictionary *messageDict = @{@"action"  : @"init",
                                  @"name"    : [userDefaults objectForKey:@"name"] ,
                                  @"channel" : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    
    [self sendData:[data bytes] length:[data length]];
}

- (void)notifyServerThatIamNotDead
{
    NSDictionary *messageDict = @{@"action"  : @"alive",
                                  @"name"    : [userDefaults objectForKey:@"name"] ,
                                  @"channel" : [userDefaults objectForKey:@"channel"]};
    NSData       *data        = [messageDict messagePack];
    [self sendData:[data bytes] length:[data length]];
}

- (void)stopListeningToServer
{
    listeningToServer = NO;
    memset(buffer, 0, MAX_BUFF);
    wait(0.01f);// to thread stop
}

- (void)startListeningToServer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Network Thread Started");
        while (listeningToServer) {
            [self serverListener];
        }
        NSLog(@"Network Thread Ended");
    });
}

- (void)serverListener
{
    @autoreleasepool {
        Address      server;
        NSInteger    bytes_read = socket.Receive(server, buffer, MAX_BUFF);
        
        if (bytes_read > 0) {
            NSData       *receivedData = [NSData dataWithBytesNoCopy:buffer length:bytes_read freeWhenDone:NO];
            NSDictionary *parsed       = [receivedData messagePackParse];
            NSString     *action       = parsed[@"action"];
            
            if ([action isEqualToString:@"list"]) {
                NSLog(@"%@", parsed);
                [delegate userList:parsed[@"userList"]];
            } else if ([action isEqualToString:@"voice"]) {
                NSInteger audioDataLength = [parsed[@"audioDataLength"] intValue];
                NSInteger dictLength      = [[parsed messagePack] length];
                
                [delegate incomingVoiceData:parsed[@"name"]
                                      voice:[receivedData subdataWithRange:NSMakeRange(dictLength, audioDataLength)]];
            }
        } else {
            wait(0.01f);
            
            if (fabs([aliveDate timeIntervalSinceNow]) > 55) {
                [self notifyServerThatIamNotDead];
            }
        }
    }
}

- (void)sendData:(const void *)data length:(NSInteger)length
{
    socket.Send([self targetAddress], data, length);
    aliveDate = [NSDate date];
}

@end
