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

+ (id)networkLayer {
    return [[self alloc] init];
}

- (id)init {
    if (self = [super init]) {
        if (!InitializeSockets()) {
            printf("failed to initialize sockets\n");
        }
        
        if (!socket.Open(0)) {
            printf("failed to create socket!\n");
        }
        userDefaults = [NSUserDefaults standardUserDefaults];
        host = [userDefaults objectForKey:@"host"];
        port = [[userDefaults objectForKey:@"port"] intValue];
        buffer = malloc(MAX_BUFF);
    }
    
    return self;
}

- (Address)targetAddress {
    @autoreleasepool {
        NSArray *hostArr = [host componentsSeparatedByString:@"."];
        return Address([hostArr[0] intValue], [hostArr[1] intValue], [hostArr[2] intValue], [hostArr[3] intValue], port);
    }
}

- (void)startCommunication {
    NSLog(@"Starting Communication");
    
    listeningToServer = YES;
    NSString     *userName    = [userDefaults objectForKey:@"name"];
    NSDictionary *messageDict = @{@"action": @"init",
                                  @"name": userName};
    
    NSData       *data        = [messageDict messagePack];
    [self sendData:[data bytes] length:[data length]];
    [NSThread detachNewThreadSelector:@selector(startListeningToServer) toTarget:self withObject:nil];
}

- (void)stopCommunication {
    NSString     *userName    = [userDefaults objectForKey:@"name"];
    NSDictionary *messageDict = @{@"action": @"disc",
                                  @"name": userName};
    
    NSData       *data        = [messageDict messagePack];
    [self sendData:[data bytes] length:[data length]];
    [self stopListeningToServer];
}

- (void)renameUser:(NSString *)oldName NewName:(NSString *)newName {
    NSDictionary *messageDict = @{@"action": @"rename",
                                  @"name": oldName,
                                  @"currentName": newName};
    
    NSData       *data        = [messageDict messagePack];
    [self sendData:[data bytes] length:[data length]];
}

- (void)reconnect {
    host = [userDefaults objectForKey:@"host"];
    port = [[userDefaults objectForKey:@"port"] intValue];
    
    NSString     *userName    = [userDefaults objectForKey:@"name"];
    NSDictionary *messageDict = @{@"action": @"init", @"name": userName};
    
    NSData       *data        = [messageDict messagePack];
    [self sendData:[data bytes] length:[data length]];
    
    //    [self stopCommunication];
    //    [self startCommunication];
}

- (void)stopListeningToServer {
    listeningToServer = NO;
    memset(buffer, 0, MAX_BUFF);
    wait(0.01f);// to thread stop
}

- (void)startListeningToServer {
    
    NSLog(@"Network Thread Started");
    while (listeningToServer) {
        [self serverListener];
    }
    NSLog(@"Network Thread Ended");
}

- (void)serverListener {
    @autoreleasepool {
        Address      server;
        NSInteger    bytes_read = socket.Receive(server, buffer, MAX_BUFF);
        
        if (bytes_read > 0) {
            NSData       *receivedData = [NSData dataWithBytesNoCopy:buffer length:bytes_read freeWhenDone:NO];
            NSDictionary *parsed       = [receivedData messagePackParse];
            NSString     *action       = parsed[@"action"];
            
            if ([action isEqualToString:@"list"]) {
                [delegate userList:parsed[@"userList"]];
            } else if ([action isEqualToString:@"voice"]) {
                NSInteger audioDataLength = [parsed[@"audioDataLength"] intValue];
                NSInteger dictLength      = [[parsed messagePack] length];
                
                [delegate incomingVoiceData:parsed[@"name"]
                                      voice:[receivedData subdataWithRange:NSMakeRange(dictLength, audioDataLength)]];
            }
        } else {
            wait(0.001f);
        }
    }
}

- (void)sendData:(const void *)data length:(NSInteger)length {
    socket.Send([self targetAddress], data, length);
}

@end
