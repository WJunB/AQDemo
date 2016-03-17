//
//  ViewController.h
//  AUDemo
//
//  Created by jun on 16/3/15.
//  Copyright © 2016年 jun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "InMemoryAudioFile.h"

@interface RootViewController : UIViewController{
    AudioStreamBasicDescription mAudioFormat;
    AudioComponentInstance      mAudioUnit;
    ExtAudioFileRef             mAudioFileRef;
    Boolean                     isRecording;
    Boolean                     isPlaying;
    InMemoryAudioFile           *inMemoryAudioFile;
}


@end

