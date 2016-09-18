//
//  NSString+hasPrefixIgnoringWhiteSpace.h
//  LogDisabler
//
//  Created by Michalis Mavris on 17/09/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (hasPrefixIgnoringWhiteSpace)

-(BOOL)hasPrefixIgnoringWhiteSpace:(NSString*)prefixStr;
@end
