#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#define QUEUE_BUFFER_SIZE 3


@interface Play : NSObject
{
    //音频参数
    AudioStreamBasicDescription audioDescription;
    // 音频播放队列
    AudioQueueRef audioQueue;
    // 音频缓存
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];
}

-(void)Play;

@end