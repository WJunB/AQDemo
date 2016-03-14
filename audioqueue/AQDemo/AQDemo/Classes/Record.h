#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#define kNumberBuffers 3

// use Audio Queue

typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];
    AudioFileID                 outputFile;
    
    unsigned long               frameSize;
    long long                   recPtr;
    int                         run;
    
} AQCallbackStruct;


@interface Record : NSObject
{
    AQCallbackStruct aqc;
    AudioFileTypeID fileFormat;
    long audioDataLength;
    Byte audioByte[999999];
    long audioDataIndex;
}
- (id) init;
- (void) start;
- (void) stop;
- (void) pause;
- (Byte *) getBytes;
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (nonatomic, assign) long audioDataLength;
@end