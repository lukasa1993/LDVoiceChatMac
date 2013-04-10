//
//  LDCustomeButton.h
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 4/2/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LDCustomeButtonEvents <NSObject>

- (void)mouseDown:(id)sender;
- (void)mouseUp:(id)sender;

@end

@interface LDCustomeButton : NSButton
{
    id<LDCustomeButtonEvents> delegate;
}

@property(nonatomic, strong) id<LDCustomeButtonEvents> delegate;

@end
