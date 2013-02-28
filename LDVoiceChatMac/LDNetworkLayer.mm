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

+(id)networkLayer
{
    return [[self alloc] init];
}

-(id)init
{
    if (self = [super init]) {
        if ( !InitializeSockets() )
        {
            printf( "failed to initialize sockets\n" );
        }
        
        
        if ( !socket.Open( 0 ) )
        {
            printf( "failed to create socket!\n" );
        }
        
        server = Address(127, 0, 0, 1, 4444);
    }
    
    return self;
}

-(void)startCommunication
{
    NSLog(@"Starting Communication");
    NSString* userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    [self sendNSDataToServer:[[NSDictionary dictionaryWithObjectsAndKeys:
                               @"init", @"action",
                               userName, @"name", nil] messagePack]];
    
    serverLitenerThread = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(listenServer)
                                                    object:nil];
    
    [serverLitenerThread start];
}

-(void)renameUser:(NSString*)oldName NewName:(NSString*)newName
{
    [self sendNSDataToServer:[[NSDictionary dictionaryWithObjectsAndKeys:
                               @"rename", @"action",
                               oldName, @"name",
                               newName, @"newName",nil] messagePack]];
}

-(void)reconnect
{
    host = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    port = [[[NSUserDefaults standardUserDefaults] objectForKey:@"port"] intValue];
    
    server = Address(127, 0, 0, 1, port);
    
    [serverLitenerThread cancel];
    serverLitenerThread = nil;
    
    [self startCommunication];
}

-(void)listenServer
{
    while ( true )
    {
        NSInteger bytes_read;
        NSMutableData* receivedData = [NSMutableData data];
        do {
            unsigned char* buffer = (unsigned char*) malloc(MAX_BUFF);
            bytes_read = socket.Receive(server,  buffer, MAX_BUFF);
            
            if (bytes_read > 0) {
                [receivedData appendData:[NSData dataWithBytes:buffer length:bytes_read]];
                NSLog(@"received packet from (%li bytes)", (long) bytes_read );
            } else {
                wait(0.25f);
            }
        } while (!bytes_read);
        
        if ([receivedData length] > 0) {
            NSLog(@"Total received packet from (%li bytes)", [receivedData length] );
        }
        
        NSDictionary* parsed = [receivedData messagePackParse];
        NSString* action = [parsed objectForKey:@"action"];
        if ([action isEqualToString:@"list"]) {
            NSArray* userList = [parsed objectForKey:@"userList"];
            [delegate userList:userList];
        } else if ([action isEqualToString:@"voice"]) {
            NSInteger audioDataLength = [[parsed objectForKey:@"audioDataLength"] intValue];
            NSInteger dictLength      = [[parsed messagePack] length];
            
            [delegate incomingVoiceData: [receivedData subdataWithRange:NSMakeRange(dictLength, audioDataLength)]];
        }
    }
}

-(void)sendNSDataToServer:(NSData*)data
{
    socket.Send( Address(127, 0, 0, 1, 4444), [data bytes], (int) [data length] );
    NSLog(@"Packet Sent: %li", (unsigned long) [data length]);
}

-(void)dealloc
{
    [super dealloc];
    ShutdownSockets();
}

@end
