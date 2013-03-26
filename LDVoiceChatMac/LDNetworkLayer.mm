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
        
        host = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
        port = [[[NSUserDefaults standardUserDefaults] objectForKey:@"port"] intValue];
    }
    
    return self;
}

- (Address)targetAddress {
    NSArray *hostArr = [host componentsSeparatedByString:@"."];
    return Address([hostArr[0] intValue], [hostArr[1] intValue], [hostArr[2] intValue], [hostArr[3] intValue], port);
}

- (void)startCommunication {
    NSLog(@"Starting Communication");
    
    listeningToServer = YES;
    NSString     *userName    = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"init", @"action", userName, @"name", nil];
    
    [self sendNSDataToServer:[messageDict messagePack]];
    [NSThread detachNewThreadSelector:@selector(startListeningToServer) toTarget:self withObject:nil];
}

- (void)stopCommunication {
    NSString     *userName    = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"disc", @"action", userName, @"name", nil];
    [self sendNSDataToServer:[messageDict messagePack]];
    
    [self stopListeningToServer];
}

- (void)renameUser:(NSString *)oldName NewName:(NSString *)newName {
    NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"rename", @"action",
                                 oldName, @"name",
                                 newName, @"currentName", nil];
    
    [self sendNSDataToServer:[messageDict messagePack]];
}

- (void)reconnect {
    host = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    port = [[[NSUserDefaults standardUserDefaults] objectForKey:@"port"] intValue];
    
    NSString     *userName    = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSDictionary *messageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"init", @"action", userName, @"name", nil];
    
    [self sendNSDataToServer:[messageDict messagePack]];

    //    [self stopCommunication];
    //    [self startCommunication];
}

- (void)stopListeningToServer {
    listeningToServer = NO;
    //    wait(0.1f);// to thread stop
}

- (void)startListeningToServer {
    void         *buffer;
    NSDictionary *parsed;
    NSString     *action;
    NSArray      *userList;
    NSData       *receivedData;
    NSInteger    bytes_read;
    NSInteger    audioDataLength;
    NSInteger    dictLength;
    Address      server;
    
    NSLog(@"Network Thread Started");
    while (listeningToServer) {
        buffer     = malloc(MAX_BUFF);
        bytes_read = socket.Receive(server, buffer, MAX_BUFF);
        
        if (bytes_read > 0) {
//            NSLog(@"Packet Received: %li", (long) bytes_read );
            
            receivedData = [NSData dataWithBytesNoCopy:buffer length:bytes_read];
            parsed       = [receivedData messagePackParse];
            action       = [parsed objectForKey:@"action"];
            
            if ([action isEqualToString:@"list"]) {
                userList = [parsed objectForKey:@"userList"];
                [delegate userList:userList];
            } else if ([action isEqualToString:@"voice"]) {
                audioDataLength = [[parsed objectForKey:@"audioDataLength"] intValue];
                dictLength      = [[parsed messagePack] length];
                
                [delegate incomingVoiceData:[parsed objectForKey:@"name"]
                                      voice:[receivedData subdataWithRange:NSMakeRange(dictLength, audioDataLength)]];
            }
        } else {
            wait(0.1f);
        }
        
        free(buffer);
    }
    NSLog(@"Network Thread Ended");
}

- (void)sendNSDataToServer:(NSData *)data {
    socket.Send([self targetAddress], [data bytes], (int) [data length]);
//    NSLog(@"Packet Sent:     %li", (unsigned long) [data length]);
}


@end
