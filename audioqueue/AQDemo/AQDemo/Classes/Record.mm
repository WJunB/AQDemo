#import "Record.h"
#import "udpsocket.h"

extern udpsocket *udp;

@implementation Record
@synthesize aqc;
@synthesize audioDataLength;

static void AQInputCallback (void                   * inUserData,
                             AudioQueueRef          inAudioQueue,
                             AudioQueueBufferRef    inBuffer,
                             const AudioTimeStamp   * inStartTime,
                             unsigned long          inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc)
{
    
    Record * engine = (__bridge Record *) inUserData;
    if (inNumPackets > 0)
    {
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }
    
    if (engine.aqc.run)
    {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
        
        
//        mRecordFormat.mSampleRate         =  44100;
//        //mRecordFormat.mFormatID           =  kAudioFormatMPEG4AAC;
//        mRecordFormat.mFormatFlags        =  0;
//        mRecordFormat.mFramesPerPacket    =  1024;
//        mRecordFormat.mChannelsPerFrame   =  2;
//        mRecordFormat.mBitsPerChannel     =  0;//表示这是一个压缩格式
//        mRecordFormat.mBytesPerPacket     =  0;//表示这是一个变比特率压缩
//        mRecordFormat.mBytesPerFrame      =  0;
//        mRecordFormat.mReserved           =  0;
//        //aqc.bufferByteSize                  =  2000;
        aqc.mDataFormat.mSampleRate = 44100;
        aqc.mDataFormat.mFormatID = kAudioFormatMPEG4AAC;
        aqc.mDataFormat.mFormatFlags = 0;
        aqc.mDataFormat.mFramesPerPacket = 1024;
        aqc.mDataFormat.mChannelsPerFrame = 2;
        aqc.mDataFormat.mBitsPerChannel = 0;
        aqc.mDataFormat.mBytesPerPacket = 0;
        aqc.mDataFormat.mBytesPerFrame = 0;
//        aqc.frameSize = kFrameSize;
        
        AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void *)(self), NULL, kCFRunLoopCommonModes,0, &aqc.queue);
        
        for (int i=0;i<kNumberBuffers;i++)
        {
            AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }
        aqc.recPtr = 0;
        aqc.run = 1;
    }
    audioDataIndex = 0;
    return self;
}

- (void) dealloc
{
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
}

- (void) start
{
    AudioQueueStart(aqc.queue, NULL);
}

- (void) stop
{
    AudioQueueStop(aqc.queue, true);
}

- (void) pause
{
    AudioQueuePause(aqc.queue);
}

- (Byte *)getBytes
{
    return audioByte;
}

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    NSLog(@"processAudioData :%ld", buffer->mAudioDataByteSize);
    //处理data：忘记oc怎么copy内存了，于是采用的C++代码，记得把类后缀改为.mm。同Play
    const int i = buffer->mAudioDataByteSize    ;
    char *data = (char*)malloc(i*sizeof(char));
    memcpy(data, buffer->mAudioData, i);
    NSData *nsdata = [NSData dataWithBytes:data length:i];
    
    audioDataLength +=i;
    [udp SendPack:nsdata isServer:YES];
    free(data);
}

@end