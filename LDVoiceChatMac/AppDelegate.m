//
//  AppDelegate.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 2/20/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "AppDelegate.h"
#import "LDVoiceChatWindowController.h"
#import "MessagePack.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define MAX_BUFF 1024
#define HOST "localhost"
#define PORT 4444

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    int sockd;
    int count;
    int addrlen;
    struct sockaddr_in my_addr, srv_addr;
    
    /* create a socket */
    sockd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockd == -1)
    {
        perror("Socket creation error");
        exit(1);
    }
    
    /* client address */
    my_addr.sin_family = AF_INET;
    my_addr.sin_addr.s_addr = INADDR_ANY;
    my_addr.sin_port = 0;
    
    bind(sockd, (struct sockaddr*)&my_addr, sizeof(my_addr));
    
    
    /* server address */
    srv_addr.sin_family = AF_INET;
    inet_aton(HOST, &srv_addr.sin_addr);
    srv_addr.sin_port = htons(PORT);
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"action", @"init", nil];
    NSData* data = [dict messagePack];
    
    sendto(sockd, [data bytes], [data length] + 1, 0, (struct sockaddr*) &srv_addr, sizeof(srv_addr));
    
    NSData* packet = [NSData data];
    addrlen = sizeof(srv_addr);
    count = recvfrom(sockd, [packet bytes], MAX_BUFF, 0, (struct sockaddr*) &srv_addr, &addrlen);
    write(1, [packet bytes], count);
    
    
    NSDictionary* parsed = [packet messagePackParse];
    NSLog(@"%@", [parsed description]);
    
    close(sockd);
    
}

@end
