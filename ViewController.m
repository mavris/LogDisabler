//
//  ViewController.m
//  LogDisabler
//
//  Created by Michalis Mavris on 20/09/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (IBAction)contactUsAction:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"mailto:info@miksoft.net"
"?subject=LogDisabler!"];
    
    assert(url != nil);
    
    // Open the URL.
    
    (void) [[NSWorkspace sharedWorkspace] openURL:url];
}
- (IBAction)sourceCodeAction:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.github.com/mavris/LogDisabler"];
    
    assert(url != nil);
    
    // Open the URL.
    
    (void) [[NSWorkspace sharedWorkspace] openURL:url];

}

@end
