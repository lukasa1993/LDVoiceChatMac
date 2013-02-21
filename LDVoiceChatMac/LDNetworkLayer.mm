//
//  LDNetworkLayer.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/21/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDNetworkLayer.h"

@implementation LDNetworkLayer

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
            return nil;
        }
        
        
        if ( !socket.Open( 0 ) )
        {
            printf( "failed to create socket!\n" );
            return nil;
        }
        
        server = Address(127, 0, 0, 1, 4444);
    }
    
    return self;
}

-(void)startCommunication
{
    NSLog(@"Starting Communication");
    NSString* userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    [self sendDictionaryToServer:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"init", @"action",
                                  userName, @"name", nil]];
//    [self listenServer];
    serverLitenerThread = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(listenServer)
                                                    object:nil];

    [serverLitenerThread start];
}

-(void)renameUser:(NSString*)oldName NewName:(NSString*)newName
{
    [self sendDictionaryToServer:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"rename", @"action",
                                  oldName, @"name",
                                  newName, @"newName",nil]];
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
        unsigned char buffer[MAX_BUFF]; 
        NSInteger bytes_read;
        NSMutableData* receivedData = [NSMutableData data];
        do {
            
            bytes_read = socket.Receive( server,  buffer, sizeof( buffer ) );
            [receivedData appendData:[NSData dataWithBytes:buffer length:bytes_read]];
            
            if (bytes_read > 0) {
                NSLog(@"received packet from (%li bytes)", (long) bytes_read );
            } else {
                wait(0.25f);
            }
        } while (!bytes_read);
        NSLog(@"Total received packet from (%li bytes)", [receivedData length] );
        
        NSDictionary* parsed = [receivedData messagePackParse];
        NSString* action = [parsed objectForKey:@"action"];
        if ([action isEqualToString:@"list"]) {
            NSArray* userList = [parsed objectForKey:@"userList"];
            for (NSInteger i = 0; i < [userList count]; i++) {
                NSDictionary* user = [userList objectAtIndex:i];
                NSLog(@"%@",[user description]);
            }
        }
    
    }
}

-(void)sendDictionaryToServer:(NSDictionary*)dict
{
    NSData* data = [dict messagePack];
    socket.Send( server, [data bytes], (int) [data length] );
}

-(void)dealloc
{
    [super dealloc];
    ShutdownSockets();
}

@end
