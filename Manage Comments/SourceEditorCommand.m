//
//  SourceEditorCommand.m
//  Manage Comments
//
//  Created by Michalis Mavris on 17/09/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "NSString+hasPrefixIgnoringWhiteSpace.h"

@implementation SourceEditorCommand {

    NSString *logString;
    NSString *logCommentString;
    NSString *regularExpressionString;
    NSString *regularExpressionCommentString;
    NSInteger mode;
}

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {

    //Checks if the file contains source code of Objective-C or Swift. Then is sets the appropriate variables
    if ([invocation.buffer.contentUTI isEqualToString:@"public.objective-c-source"]) {
            logString = @"NSLog(";
            logCommentString=@"DSLog(";
            regularExpressionString =@"NSLog\\([^\\)]*\\)[\\s]*\\;";
            regularExpressionCommentString=@"\\/\\*DSLog\\([^\\)]*\\)[\\s]*\\;\\*\\/";
    }
    else if ([invocation.buffer.contentUTI isEqualToString:@"public.swift-source"]){
            logString = @"print(";
            logCommentString = @"drint(";
            regularExpressionString =@"(Swift.){0,1}print\\([^\\)]*\\)[\\s]*[\\;]{0,1}";
            regularExpressionCommentString=@"\\/\\*(Swift.){0,1}drint\\([^\\)]*\\)[\\s]*[\\;]{0,1}\\*\\/";
    }
    else {
        
        return;
    }
    
    //Checks which button has been clicked and is executing the appropriate action
    if ([invocation.commandIdentifier isEqualToString:@"disableComments"]) {
        
        //Looping trhroug the lines
        for(NSString *str in invocation.buffer.lines) {
            
            //Ingnoring lines starting with //
            if ([str hasPrefixIgnoringWhiteSpace:@"//"]) {
                continue;
            }
            
            //If the line contains NSLog( or print( then process it
            if ([str containsString:logString]) {
                
                //Calling the commentLogsFromLine that returns the line commented
                NSString *commentedString = [self commentLogFromLine:str];
                
                //Getting the index of the line
                NSInteger index =  [invocation.buffer.lines indexOfObject:str];
                
                //Replacing the current line with the commented one
                [invocation.buffer.lines replaceObjectAtIndex:index withObject:commentedString];
            }
        }
    }
    else
    if ([invocation.commandIdentifier isEqualToString:@"enableComments"]) {
        
        //Looping trhroug the line
        for(NSString *str in invocation.buffer.lines) {
            
            //Ingnoring lines starting with //
            if ([str hasPrefixIgnoringWhiteSpace:@"//"]) {
                continue;
            }
            
            //If the line contains NSLog( or print( then process it
            if ([str containsString:logCommentString]) {
                
                //Calling the unCommentLogsFromLine that returns the line commented
                NSString *unCommentedString = [self unCommentLogFromLine:str];
                
                //Getting the index of the line
                NSInteger index =  [invocation.buffer.lines indexOfObject:str];

                //Replacing the current line with the commented one
                [invocation.buffer.lines replaceObjectAtIndex:index withObject:unCommentedString];
            }
        }
    }

    completionHandler(nil);

}

-(NSString*)commentLogFromLine:(NSString*)lineStr {
    
    //The regular expression string to be used (is different for Objective-C and Swift)
    NSString  *regexStr =regularExpressionString;
    
    //The regular expression
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    //The array returned from regular expression with the matches of logs
    NSArray *arrayOfAllMatches = [regex matchesInString:lineStr options:0 range:NSMakeRange(0, [lineStr length])];
    
    //The mutable string we are going to use in order to modify the line
    NSMutableString *mutStr = [[NSMutableString alloc]initWithString:lineStr];
    
    //Looping throug results (where the regular expression matched)
    for (NSTextCheckingResult *textCheck in arrayOfAllMatches) {
        
        if (textCheck) {
            //Getting the range of the match
            NSRange matchRange = [textCheck range];
            
            //Getting the log to be commented
            NSString *strToReplace = [lineStr substringWithRange:matchRange];
            
            //Adding coments to the string
            NSMutableString *commentedStr = [NSMutableString stringWithFormat:@"/*%@*/",[lineStr substringWithRange:matchRange]];
            
            
            //Getting the range of the NSLog( or print(
            NSRange rOriginal = [commentedStr rangeOfString:logString];
            
            //Replacing the NSLog or print with a new string. We do that so we can identify the logs that we commented out in the "Enable Comments" and replace only those.
            if (NSNotFound != rOriginal.location) {
                [commentedStr replaceOccurrencesOfString:logString withString:logCommentString options:NSCaseInsensitiveSearch range:rOriginal];
            }
            
            //Replacing the log with the commented one
            [mutStr replaceOccurrencesOfString:strToReplace withString:commentedStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutStr length])];
            
        }
    }
    
    return [NSString stringWithString:mutStr];
    
}


-(NSString*)unCommentLogFromLine:(NSString*)lineStr {
    
    //The regular expression string to be used (is different for Objective-C and Swift)
    NSString  *regexStr =regularExpressionCommentString;
    
    //The regular expression
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];

    //The array returned from regular expression with the matches of logs
    NSArray *arrayOfAllMatches = [regex matchesInString:lineStr options:0 range:NSMakeRange(0, [lineStr length])];
    
    //The mutable string we are going to use in order to modify the line
    NSMutableString *mutStr = [[NSMutableString alloc]initWithString:lineStr];
   
    //Looping throug results (where the regular expression matched)
    for (NSTextCheckingResult *textCheck in arrayOfAllMatches) {
        
        if (textCheck) {
            //Getting the range of the match
            NSRange matchRange = [textCheck range];
         
            //Getting the log to be uncommented
            NSString *strToReplace = [lineStr substringWithRange:matchRange];
            
            //The string that will be modified and remove all comments
            NSMutableString *clearCommentStr = [NSMutableString stringWithString:strToReplace];
            
            //Removing the comments
            [clearCommentStr replaceOccurrencesOfString:@"/*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [clearCommentStr length])];
            [clearCommentStr replaceOccurrencesOfString:@"*/" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [clearCommentStr length])];
            
            //Getting the range of the DSLog( or drint(
            NSRange rOriginal = [clearCommentStr rangeOfString:logCommentString];
            
            //Replacing the identifier string so it will be replaced with NSLog or print
            if (NSNotFound != rOriginal.location) {
                
                [clearCommentStr replaceOccurrencesOfString:logCommentString withString:logString options:NSCaseInsensitiveSearch range:rOriginal];
            }
            
            //Replacing the log with the uncommented one
            [mutStr replaceOccurrencesOfString:strToReplace withString:clearCommentStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutStr length])];
            
        }
    }
    
    return [NSString stringWithString:mutStr];
    
}

@end
