//
//  AQSController.mm
//  remoteMedicalUDP+AV
//
//  Created by jun on 16/2/1.
//  Copyright © 2016年 jun. All rights reserved.
//

#import "AQSController.h"
#import "play.h"
#import "Record.h"
@implementation AQSController{
    
    Record      *recorder;
    Play        *player;
    
}

- (void)record{
    recorder = [[Record alloc]init];
    [recorder start];
    
}
- (void)replay{
    player  = [Play alloc];

}


-(void) stop{
    if (recorder) {
        [recorder stop];
    }
}



#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
    
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
//    AQSController *THIS = (__bridge AQSController*)inClientData;
    if (inID == kAudioSessionProperty_AudioRouteChange)
    {
        CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
        //CFShow(routeDictionary);
        CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
        SInt32 reasonVal;
        CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
        if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
        {
            /*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
             if (oldRoute)
             {
             printf("old route:\n");
             CFShow(oldRoute);
             }
             else
             printf("ERROR GETTING OLD AUDIO ROUTE!\n");
             
             CFStringRef newRoute;
             UInt32 size; size = sizeof(CFStringRef);
             OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
             if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
             else
             {
             printf("new route:\n");
             CFShow(newRoute);
             }*/
            
            if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
            {
               
            }
            
            // stop the queue if we had a non-policy route change

        }
    }
    else if (inID == kAudioSessionProperty_AudioInputAvailable)
    {
        if (inDataSize == sizeof(UInt32)) {
            UInt32 isAvailable = *(UInt32*)inData;
            // disable recording if input is not available
        }
    }
}

#pragma mark Initialization routines

#pragma mark Initialization routines
- (void)awakeFromNib
{
    // Allocate our singleton instance for the recorder & player object

    
    OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, (__bridge void*)self);
    if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
    else
    {
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        if (error) printf("couldn't set audio category!");
        
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void*)self);
        if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        UInt32 inputAvailable = 0;
        UInt32 size = sizeof(inputAvailable);
        
        // we do not want to allow recording if input is not available
        error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
        if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
        
        
        // we also need to listen to see if input availability changes
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, (__bridge void*)self);
        if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        
        error = AudioSessionSetActive(true);
        if (error) printf("AudioSessionSetActive (true) failed");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
        
        // disable the play button since we have no recording to play yet
        
    }
}


#pragma mark Cleanup
- (void)dealloc
{

}

@end