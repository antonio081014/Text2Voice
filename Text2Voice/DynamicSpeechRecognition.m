//
//  DynamicSpeechRecognition.m
//  Text2Voice
//
//  Created by Antonio081014 on 6/15/13.
//  Copyright (c) 2013 Antonio081014.com. All rights reserved.
//

#import "DynamicSpeechRecognition.h"
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/FliteController.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/OpenEarsEventsObserver.h>

@interface DynamicSpeechRecognition() <OpenEarsEventsObserverDelegate>

@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) PocketsphinxController *pocketController;
@property (nonatomic, strong) FliteController *fliteController;

@property (nonatomic, strong) NSString *pathToDynamicallyGeneratedGrammar;
@property (nonatomic, strong) NSString *pathToDynamicallyGeneratedDictionary;


@end

@implementation DynamicSpeechRecognition

- (PocketsphinxController *)pocketController{
    if (!_pocketController) {
        _pocketController = [[PocketsphinxController alloc] init];
    }
    return _pocketController;
}

- (FliteController *)fliteController{
    if (!_fliteController) {
        _fliteController = [[FliteController alloc] init];
    }
    return _fliteController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver{
    if (!_openEarsEventsObserver) {
        _openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
    }
    return _openEarsEventsObserver;
}

- (Slt *)slt {
	if (_slt == nil) {
		_slt = [[Slt alloc] init];
	}
	return _slt;
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis
                         recognitionScore:(NSString *)recognitionScore
                              utteranceID:(NSString *)utteranceID {
    
    if (self.debug) {
        NSLog(@"Input Processed");
    }
    
    if (self.fliteController.speechInProgress) {
        NSLog(@"Flite are possessed;");
    } else {
        if (self.instantSpeak) {
            [self say:[NSString stringWithFormat:@"You said %@", hypothesis]];
        }
        
        [self.delegate getHypothesis:hypothesis];
    }
}

#pragma mark -
#pragma mark AUDIO SESSION
// An optional delegate method of OpenEarsEventsObserver which informs that there was an interruption to the audio session (e.g. an incoming phone call).
- (void) audioSessionInterruptionDidBegin {
    NSLog(@"AudioSession interruption began."); // Log it.
    [self.pocketController stopListening]; // React to it by telling Pocketsphinx to stop listening since it will need to restart its loop after an interruption.
}

// An optional delegate method of OpenEarsEventsObserver which informs that the interruption to the audio session ended.
- (void) audioSessionInterruptionDidEnd {
    NSLog(@"AudioSession interruption ended."); // Log it.
    // We're restarting the previously-stopped listening loop.
    [self.pocketController startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedGrammar dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary languageModelIsJSGF:FALSE];
}

// An optional delegate method of OpenEarsEventsObserver which informs that the audio input became unavailable.
- (void) audioInputDidBecomeUnavailable {
    NSLog(@"The audio input has become unavailable"); // Log it.
    [self.pocketController stopListening]; // React to it by telling Pocketsphinx to stop listening since there is no available input
}

// An optional delegate method of OpenEarsEventsObserver which informs that the unavailable audio input became available again.
- (void) audioInputDidBecomeAvailable {
    NSLog(@"The audio input is available"); // Log it.
    [self.pocketController startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedGrammar dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary languageModelIsJSGF:FALSE];
}

#pragma mark -
#pragma mark CALIBRATION
// An optional delegate method of OpenEarsEventsObserver which informs that the Pocketsphinx recognition loop hit the calibration stage in its startup.
// This might be useful in debugging a conflict between another sound class and Pocketsphinx. Another good reason to know when you're in the middle of
// calibration is that it is a timeframe in which you want to avoid playing any other sounds including speech so the calibration will be successful.
- (void) pocketsphinxDidStartCalibration {
    if (self.debug) {
        NSLog(@"Pocketsphinx calibration has started."); // Log it.
    }
}

// An optional delegate method of OpenEarsEventsObserver which informs that the Pocketsphinx recognition loop completed the calibration stage in its startup.
// This might be useful in debugging a conflict between another sound class and Pocketsphinx.
- (void) pocketsphinxDidCompleteCalibration {
    if (self.debug) {
        NSLog(@"Pocketsphinx calibration is complete."); // Log it.
    }
    
    self.fliteController.duration_stretch = .9; // Change the speed
    self.fliteController.target_mean = 1.2; // Change the pitch
    self.fliteController.target_stddev = 1.5; // Change the variance
    
    [self.fliteController say:@"Welcome to Dynamic OpenEars." withVoice:self.slt];
    // The same statement with the pitch and other voice values changed.
    
    self.fliteController.duration_stretch = 1.0; // Reset the speed
    self.fliteController.target_mean = 1.0; // Reset the pitch
    self.fliteController.target_stddev = 1.0; // Reset the variance
}

#pragma mark -
#pragma mark POCKETSPHINX STATUS

- (void) pocketsphinxRecognitionLoopDidStart {
    if (self.debug) {
        NSLog(@"Pocketsphinx is starting up."); // Log it.
    }
}

- (void) pocketsphinxDidStartListening {
    if (self.debug) {
        NSLog(@"Pocketsphinx is now listening."); // Log it.
    }
}

- (void) pocketsphinxDidDetectSpeech {
    if (self.debug) {
        NSLog(@"Pocketsphinx has detected speech."); // Log it.
    }
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
// This was added because developers requested being able to time the recognition speed without the speech time. The processing time is the time between
// this method being called and the hypothesis being returned.
- (void) pocketsphinxDidDetectFinishedSpeech {
    if (self.debug) {
        NSLog(@"Pocketsphinx has detected a second of silence, concluding an utterance."); // Log it.
    }
}

- (void) pocketsphinxDidStopListening {
    if (self.debug) {
        NSLog(@"Pocketsphinx has stopped listening."); // Log it.
    }
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
// Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
// in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
// or as a result of the PocketsphinxController being told to suspend recognition via the suspendRecognition method.
- (void) pocketsphinxDidSuspendRecognition {
    if (self.debug) {
        NSLog(@"Pocketsphinx has suspended recognition."); // Log it.
    }
}

// An optional delegate method of OpenEarsEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
// having been suspended it is now resuming.  This can happen as a result of Flite speech completing
// on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
// or as a result of the PocketsphinxController being told to resume recognition via the resumeRecognition method.
- (void) pocketsphinxDidResumeRecognition {
    if (self.debug) {
        NSLog(@"Pocketsphinx has resumed recognition."); // Log it.
    }
}

// An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
// recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    if (self.debug) {
        NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
    }
}

// An optional delegate method of OpenEarsEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
// complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
- (void) fliteDidStartSpeaking {
    if (self.debug) {
        NSLog(@"Flite has started speaking"); // Log it.
    }
}

// An optional delegate method of OpenEarsEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
// complex interaction between sound classes.
- (void) fliteDidFinishSpeaking {
    if (self.debug) {
        NSLog(@"Flite has finished speaking"); // Log it.
    }
}

- (void) pocketSphinxContinuousSetupDidFail {
    // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
    if (self.debug) {
        NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OPENEARSLOGGING in OpenEarsConfig.h to learn more."); // Log it.
    }
}


- (BOOL) setup{
    
    self.openEarsEventsObserver.delegate = self;
    
    LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
    
    languageModelGenerator.verboseLanguageModelGenerator = TRUE; // Uncomment me for verbose debug output
    
    // generateLanguageModelFromArray:withFilesNamed returns an NSError which will either have a value of noErr if everything went fine or a specific error if it didn't.
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:self.words2Recognize
                                                             withFilesNamed:self.filenameToSave];
    
    NSDictionary *dynamicLanguageGenerationResultsDictionary = nil;
    if([error code] != noErr) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
        return NO;
    } else {
        dynamicLanguageGenerationResultsDictionary = [error userInfo];
        // A useful feature of the fact that generateLanguageModelFromArray:withFilesNamed: always returns an NSError is that when it returns noErr (meaning there was
        // no error, or an [NSError code] of zero), the NSError also contains a userInfo dictionary which contains the path locations of your new files.
        
        // What follows demonstrates how to get the paths for your created dynamic language models out of that userInfo dictionary.
        NSString *lmFile = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMFile"];
        NSString *dictionaryFile = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryFile"];
        NSString *lmPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMPath"];
        NSString *dictionaryPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryPath"];
        if (self.debug) {
            NSLog(@"Dynamic language generator completed successfully, you can find your new files %@\n and \n%@\n at the paths \n%@ \nand \n%@", lmFile,dictionaryFile,lmPath,dictionaryPath);
        }
        
        self.pathToDynamicallyGeneratedGrammar = lmPath;
        // We'll set our new .languagemodel file to be the one to get switched to when the words "CHANGE MODEL" are recognized.
        self.pathToDynamicallyGeneratedDictionary = dictionaryPath;
        // We'll set our new dictionary to be the one to get switched to when the words "CHANGE MODEL" are recognized.
        
    }
    return YES;
}

- (void) startVoiceRecognition{
    if (![self setup]) {
        NSLog(@"Setup failed");
        return;
    }
    
    [self.pocketController startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedGrammar
                                                dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary
                                             languageModelIsJSGF:FALSE];
}

- (void) stopVoiceRecognition{
    [self.pocketController stopListening];
}

- (void) suspendVoiceRecognition{
    [self.pocketController suspendRecognition];
}

- (void) resumeVoiceRecognition{
    [self.pocketController resumeRecognition];
}

- (float) pocketsphinxInputLevel{
    return [self.pocketController pocketsphinxInputLevel];
}

- (float) fliteOutputLevel{
    return [self.fliteController fliteOutputLevel];
}

- (void) say:(NSString *)sentence{
    if (self.fliteController.speechInProgress == NO) {
        [self.fliteController say:sentence withVoice:self.slt];
    } else {
        if (self.debug) {
            NSLog(@"The Flite Controller is under process, try it later");
        }
    }
}
@end