//
//  DynamicSpeechRecognition.h
//  Text2Voice
//
//  Created by Antonio081014 on 6/15/13.
//  Copyright (c) 2013 Antonio081014.com. All rights reserved.
//

#import <OpenEars/OpenEarsEventsObserver.h>
#import <Slt/Slt.h>
#import <UIKit/UIKit.h>

@protocol DynamicSpeechRecognitionDelegate <NSObject>

@required
//This help you get the words recognized from speech
- (void) getHypothesis:(NSString *)hypothesis;

@end

@interface DynamicSpeechRecognition : NSObject <OpenEarsEventsObserverDelegate>

@property (nonatomic) BOOL debug;

//The filename of to-be generated words.
@property (nonatomic, strong) NSString *filenameToSave;
//The voice to use, this is mainly for text2speech feature;
@property (nonatomic, strong) Slt *slt;;
//The words to be recognized intentionally.
@property (nonatomic, strong) NSArray *words2Recognize;
//Flag for verify your speech recognition system by saying the word out instantly after the recognition;
@property (nonatomic) BOOL instantSpeak;

@property (retain) id<DynamicSpeechRecognitionDelegate> delegate;

- (void) startVoiceRecognition;
- (void) stopVoiceRecognition;
- (void) suspendVoiceRecognition;
- (void) resumeVoiceRecognition;
- (float) pocketsphinxInputLevel;
- (float) fliteOutputLevel;
- (void) say:(NSString *)sentence;

@end