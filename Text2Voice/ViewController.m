//
//  ViewController.m
//  Text2Voice
//
//  Created by Antonio081014 on 6/15/13.
//  Copyright (c) 2013 Antonio081014.com. All rights reserved.
//

#import "ViewController.h"
#import "DynamicSpeechRecognition.h"

@interface ViewController () <DynamicSpeechRecognitionDelegate>

@property (nonatomic) BOOL flag;
@property (strong, nonatomic) IBOutlet UILabel *display;
@property (strong, nonatomic) IBOutlet UILabel *displayHint;

//@property (strong, nonatomic) StaticSpeechRecognition *voiceRecognition;
@property (nonatomic, strong) DynamicSpeechRecognition *voiceRecognition;

@end

@implementation ViewController

@synthesize flag = _flag;
@synthesize display = _display;
@synthesize displayHint = _displayHint;

@synthesize voiceRecognition = _voiceRecognition;

//  // Initialization;
- (DynamicSpeechRecognition *)voiceRecognition{
    if (!_voiceRecognition) {
        _voiceRecognition = [[DynamicSpeechRecognition alloc] init];
        // All capital letters.
        _voiceRecognition.words2Recognize = [NSArray arrayWithObjects:@"HOLD",
                                                                            @"HISTORY",
                                                                            @"MAX",
                                                                            @"MIN",
                                                                            @"CHART",
                                                                            @"TABLE",
                                                                            @"CLEAR",
                                                                            @"EXIT",
                                                                            nil];
        _voiceRecognition.filenameToSave = @"OpenEarsDynamicGrammar";
        _voiceRecognition.debug = NO;
        _voiceRecognition.instantSpeak = NO;
    }
    return _voiceRecognition;
}

- (void) getHypothesis:(NSString *)hypothesis{
    NSLog(@"Get the word %@", hypothesis);
}

- (IBAction)confirm:(UIButton *)sender {
    
    [self.voiceRecognition startVoiceRecognition];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.flag = YES;
    
    self.voiceRecognition.delegate = self;
}

- (void)viewDidUnload
{
    [self setDisplay:nil];
    [self setDisplayHint:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end