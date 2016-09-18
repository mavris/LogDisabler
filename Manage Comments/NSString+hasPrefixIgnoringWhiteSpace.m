//
//  NSString+hasPrefixIgnoringWhiteSpace.m
//  LogDisabler
//
//  Created by Michalis Mavris on 17/09/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "NSString+hasPrefixIgnoringWhiteSpace.h"

@implementation NSString (hasPrefixIgnoringWhiteSpace)

-(BOOL)hasPrefixIgnoringWhiteSpace:(NSString*)prefixStr {
    
    NSInteger i = 0;
    
    while ((i < [self length]) && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }

    NSString *clearText = [self substringFromIndex:i];
    
    return [clearText hasPrefix:@"//"];
    
};
@end
