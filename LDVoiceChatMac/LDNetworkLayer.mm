//
//  LDNetworkLayer.mm
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/21/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDNetworkLayer.hh"

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
        
        server = Address(127, 0, 0, 1, PORT);
    }
    
    return self;
}

-(void)startCommunication
{
    [self sendDictionaryToServer:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"init", @"action",
                                  @"name", @"mtvnela", nil]];
    [self listenServer];
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
            [receivedData appendData:[NSData dataWithBytesNoCopy:buffer length:bytes_read]];
            
            NSLog(@"received packet from (%li bytes)", (long) bytes_read );
        } while (!bytes_read);
        NSLog(@"Total received packet from (%li bytes)", [receivedData length] );
        
        NSDictionary* parsed = [receivedData messagePackParse];
        NSString* action = [parsed objectForKey:@"action"];
        if ([action isEqualToString:@"list"]) {
            
        }
        
        wait(0.25f);
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
