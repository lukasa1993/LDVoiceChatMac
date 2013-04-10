//
//  LDCustomeFormatter.m
//  LDVoiceChatMac
//
//  Created by Luka Dodelia on 4/4/13.
//  Copyright (c) 2013 Luka Dodelia. All rights reserved.
//

#import "LDCustomeFormatter.h"

@implementation LDCustomeFormatter

- (void)initialize
{
    controlSet = [[NSMutableCharacterSet alloc] init];
    
    NSRange lowerCaseAlphaRange;
    lowerCaseAlphaRange.location = (unsigned int)'a';
    lowerCaseAlphaRange.length = 26;
    [controlSet addCharactersInRange:lowerCaseAlphaRange];

    NSRange upperCaseAlphaRange;
    upperCaseAlphaRange.location = (unsigned int)'A';
    upperCaseAlphaRange.length = 26;
    [controlSet addCharactersInRange:upperCaseAlphaRange];
    
    NSRange digitsRange;
    digitsRange.location = (unsigned int)'0';
    digitsRange.length = 10;
    [controlSet addCharactersInRange:digitsRange];
    
    [controlSet addCharactersInString:@"-._"];
    
    [controlSet invert];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    return anObject;
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error {
    NSString *trimmedReplacement = [[string componentsSeparatedByCharactersInSet:controlSet] componentsJoinedByString:@""];
    *obj = trimmedReplacement;
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error
{
	NSRange inRange = [partialString rangeOfCharacterFromSet:controlSet];
    
	if(inRange.location != NSNotFound || [partialString length] > 11)
	{
		*error = @"Illegal value.";
		NSBeep();
		return NO;
	}
    
	*newString = partialString;
	return YES;
}

@end
