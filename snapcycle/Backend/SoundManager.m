//
//  SoundManager.m
//  snapcycle
//
//  Created by taylorka on 8/2/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "SoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation SoundManager

+ (void)playSuccessSound {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL soundOff = [defaults boolForKey:@"soundOff"];
    
    if (!soundOff) {
        [self playSoundFromPath:[[NSBundle mainBundle] pathForResource:@"success-sound" ofType:@"mp3"]];
    }
}

+ (void)playFailureSound {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL soundOff = [defaults boolForKey:@"soundOff"];
    if (!soundOff) {
        [self playSoundFromPath:[[NSBundle mainBundle] pathForResource:@"fail-sound" ofType:@"mp3"]];
    }
}

+ (void)playSoundFromPath:(NSString*)soundPath {
    // Play sounds
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
