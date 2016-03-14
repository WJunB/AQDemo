#import "Play.h"
extern char* Gbuffer;
#define  EVERY_READ_LENGTH 5000
@interface Play()
{
//    char *audioByte;
    long audioDataCurrent;
    long audioDataLength;
}
@end

@implementation Play

//回调函数(Callback)的实现
static void BufferCallback(void *inUserData,AudioQueueRef inAQ,AudioQueueBufferRef buffer){
    
    NSLog(@"processAudioData :%u", (unsigned int)buffer->mAudioDataByteSize);
    
    Play* player=(__bridge Play*)inUserData;
    
    [player FillBuffer:inAQ queueBuffer:buffer];
}

//缓存数据读取方法的实现
-(void)FillBuffer:(AudioQueueRef)queue queueBuffer:(AudioQueueBufferRef)buffer
{
    if(audioDataCurrent + EVERY_READ_LENGTH < audioDataLength)
    {
        if (audioDataCurrent+EVERY_READ_LENGTH>50000) {
            memcpy(buffer->mAudioData, Gbuffer+(audioDataCurrent%50000), (50000-audioDataCurrent));
            audioDataCurrent = 0;
            buffer->mAudioDataByteSize =(50000-audioDataCurrent);
        }
        memcpy(buffer->mAudioData, Gbuffer+(audioDataCurrent%50000), EVERY_READ_LENGTH);
        audioDataCurrent += EVERY_READ_LENGTH;
        buffer->mAudioDataByteSize =EVERY_READ_LENGTH;
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }
    
}

-(void)SetAudioFormat
{
    ///设置音频参数
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
    
    
    
    audioDescription.mSampleRate  = 44100;//采样率
    audioDescription.mFormatID    = kAudioFormatMPEG4AAC;
    audioDescription.mFormatFlags =  0;//|kAudioFormatFlagIsNonInterleaved;
    audioDescription.mChannelsPerFrame = 2;
    audioDescription.mFramesPerPacket  = 1024;//每一个packet一侦数据
    audioDescription.mBitsPerChannel   = 0;//av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)*8;//每个采样点16bit量化
    audioDescription.mBytesPerFrame    = 0;
    audioDescription.mBytesPerPacket   = 0;
    
    [self CreateAudioQueue];
}

-(void)CreateAudioQueue
{
    [self Cleanup];
    //使用player的内部线程播
    AudioQueueNewOutput(&audioDescription, BufferCallback, (__bridge void *)(self), nil, nil, 0, &audioQueue);
    if(audioQueue)
    {
        ////添加buffer区
        for(int i=0;i<QUEUE_BUFFER_SIZE;i++)
        {
            int result =  AudioQueueAllocateBuffer(audioQueue, EVERY_READ_LENGTH, &audioQueueBuffers[i]);
            ///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
            NSLog(@"AudioQueueAllocateBuffer i = %d,result = %d",i,result);
        }
    }
}

-(void)Cleanup
{
    if(audioQueue)
    {
        NSLog(@"Release AudioQueueNewOutput");
        
        [self Stop];
        for(int i=0; i < QUEUE_BUFFER_SIZE; i++)
        {
            AudioQueueFreeBuffer(audioQueue, audioQueueBuffers[i]);
            audioQueueBuffers[i] = nil;
        }
        audioQueue = nil;
    }
}

-(void)Stop
{
    NSLog(@"Audio Player Stop");
    
    AudioQueueFlush(audioQueue);
    AudioQueueReset(audioQueue);
    AudioQueueStop(audioQueue,TRUE);
}

-(void)Play
{
    [self Stop];

    
    NSLog(@"Audio Play Start >>>>>");
    
    [self SetAudioFormat];
    
    AudioQueueReset(audioQueue);
    audioDataCurrent = 0;
    for(int i=0; i<QUEUE_BUFFER_SIZE; i++)
    {
        [self FillBuffer:audioQueue queueBuffer:audioQueueBuffers[i]];
    }
    AudioQueueStart(audioQueue, NULL);
}

@end