//
//  ViewController.m
//  AUDemo
//
//  Created by jun on 16/3/15.
//  Copyright © 2016年 jun. All rights reserved.
//



#import "RootViewController.h"

#define kChannels   2
#define kOutputBus  0
#define kInputBus   1
@interface RootViewController ()
@end

@implementation RootViewController
- (id)init
{
    self = [super init];
    if (self) {
        isRecording=FALSE;
        isPlaying=FALSE;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
static void CheckError(OSStatus error,const char *operaton){
    if (error==noErr) {
        return;
    }
    char errorString[20]={};
    *(UInt32 *)(errorString+1)=CFSwapInt32HostToBig(error);
    if (isprint(errorString[1])&&isprint(errorString[2])&&isprint(errorString[3])&&isprint(errorString[4])) {
        errorString[0]=errorString[5]='\'';
        errorString[6]='\0';
    }else{
        sprintf(errorString, "%d",(int)error);
    }
    fprintf(stderr, "Error:%s (%s)\n",operaton,errorString);
    exit(1);
}
void audioInterruptionListener(void *inClientData,UInt32 inInterruptionState){
    printf("Interrupted! inInterruptionState=%ld\n",inInterruptionState);
    //RootViewController *appDelegate=(RootViewController *)inClientData;
    switch (inInterruptionState) {
        case kAudioSessionBeginInterruption:
            break;
        case kAudioSessionEndInterruption:
            /*
             CheckError(AudioSessionSetActive(true), "Couldn't set audio session active");
             CheckError(AudioUnitInitialize(appDelegate->mAudioUnit), "Couldn't initialize RIO unit");
             CheckError(AudioOutputUnitStart(appDelegate->mAudioUnit), "Couldn't start RIO unit");
             */
            break;
        default:
            break;
    }
}
void audioRouteChangeListener(  void                    *inClientData,
                              AudioSessionPropertyID    inID,
                              UInt32                    inDataSize,
                              const void                *inData){
    printf("audioRouteChangeListener");
    /*
     CFStringRef routeStr;
     UInt32 properSize=sizeof(routeStr);
     AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &properSize, &routeStr);
     NSString *routeNSStr=(NSString *)routeStr;
     NSLog(@"audioRouteChange::%@",routeNSStr);//none:ReceiverAndMicrophone ipod:HeadphonesAndMicrophone iphone:HeadsetInOut xiaomi:HeadsetInOut
     UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:routeNSStr message:routeNSStr delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"other", nil];
     [alertView show];
     [alertView release];
     */
}
OSStatus recordCallback(void                                        *inRefCon,
                        AudioUnitRenderActionFlags        *ioActionFlags,
                        const AudioTimeStamp              *inTimeStamp,
                        UInt32                            inBusNumber,
                        UInt32                            inNumberFrames,
                        AudioBufferList                   *ioData){
    printf("record::%ld,",inNumberFrames);
    //double timeInSeconds = inTimeStamp->mSampleTime / kSampleRate;
    //printf("\n%fs inBusNumber:%lu inNumberFrames:%lu", timeInSeconds, inBusNumber, inNumberFrames);
    
    AudioBufferList bufferList;
    UInt16 numSamples=inNumberFrames*kChannels;
    UInt16 samples[numSamples];
    memset (&samples, 0, sizeof (samples));
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = samples;
    bufferList.mBuffers[0].mNumberChannels = kChannels;
    bufferList.mBuffers[0].mDataByteSize = numSamples*sizeof(UInt16);
    RootViewController* THIS = (__bridge RootViewController *)inRefCon;
    CheckError(AudioUnitRender(THIS->mAudioUnit,
                               ioActionFlags,
                               inTimeStamp,
                               kInputBus,
                               inNumberFrames,
                               &bufferList),"AudioUnitRender failed");
    
    // Now, we have the samples we just read sitting in buffers in bufferList
    ExtAudioFileWriteAsync(THIS->mAudioFileRef, inNumberFrames, &bufferList);
    return noErr;
}
OSStatus playCallback(void                                      *inRefCon,
                      AudioUnitRenderActionFlags      *ioActionFlags,
                      const AudioTimeStamp            *inTimeStamp,
                      UInt32                          inBusNumber,
                      UInt32                          inNumberFrames,
                      AudioBufferList                 *ioData){
    printf("play::%ld,",inNumberFrames);
    RootViewController* this = (__bridge RootViewController *)inRefCon;
    
    /*
     UInt8 *frameBuffer = ioData->mBuffers[0].mData;
     UInt32 count=inNumberFrames*4;
     for (int j = 0; j < count; ){
     UInt32 packet=[this->inMemoryAudioFile getNextFrame];
     frameBuffer[j]=packet;
     frameBuffer[j+1]=packet>>8;
     //Above for the left channel, right channel following
     frameBuffer[j+2]=packet>>16;
     frameBuffer[j+3]=packet>>24;
     j+=4;
     }
     */
    /*
     UInt16 *frameBuffer = ioData->mBuffers[0].mData;
     UInt32 count=inNumberFrames*2;
     for (int j = 0; j < count; ){
     UInt32 packet=[this->inMemoryAudioFile getNextFrame];
     frameBuffer[j]=packet;//left channel
     frameBuffer[j+1]=packet>>16;//right channel
     j+=2;
     }
     */
    
    UInt32 *frameBuffer = ioData->mBuffers[0].mData;
    UInt32 count=inNumberFrames;
    for (int j = 0; j < count; j++){
        frameBuffer[j] = [this->inMemoryAudioFile getNextPacket];//Stereo channels
    }
    
    return noErr;
}
-(void)configAudio{
    //Upon launch, the application automatically gets a singleton audio session.
    //Initialize a session and registering an interruption callback
    CheckError(AudioSessionInitialize(NULL, kCFRunLoopDefaultMode, audioInterruptionListener, (__bridge void *)(self)), "couldn't initialize the audio session");
    
    //Add a AudioRouteChange listener
    CheckError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListener, (__bridge void *)(self)),"couldn't add a route change listener");
    
    //Is there an audio input device available
    UInt32 inputAvailable;
    UInt32 propSize=sizeof(inputAvailable);
    CheckError(AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &propSize, &inputAvailable), "not available for the current input audio device");
    if (!inputAvailable) {
        /*
         UIAlertView *noInputAlert =[[UIAlertView alloc] initWithTitle:@"error" message:@"not available for the current input audio device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [noInputAlert show];
         [noInputAlert release];
         */
        return;
    }
    
    //Adjust audio hardware I/O buffer duration.If I/O latency is critical in your app, you can request a smaller duration.
    Float32 ioBufferDuration = .005;
    CheckError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(ioBufferDuration), &ioBufferDuration),"couldn't set the buffer duration on the audio session");
    
    //Set the audio category
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    CheckError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set the category on the audio session");
    
    UInt32 override=true;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(override), &override);
    
    //Get hardware sample rate and setting the audio format
    Float64 sampleRate;
    UInt32 sampleRateSize=sizeof(sampleRate);
    CheckError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &sampleRateSize, &sampleRate), "Couldn't get hardware samplerate");
    mAudioFormat.mSampleRate         = sampleRate;
    mAudioFormat.mFormatID           = kAudioFormatLinearPCM;
    mAudioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    mAudioFormat.mFramesPerPacket    = 1;
    mAudioFormat.mChannelsPerFrame   = kChannels;
    mAudioFormat.mBitsPerChannel     = 16;
    mAudioFormat.mBytesPerFrame      = mAudioFormat.mBitsPerChannel*mAudioFormat.mChannelsPerFrame/8;
    mAudioFormat.mBytesPerPacket     = mAudioFormat.mBytesPerFrame*mAudioFormat.mFramesPerPacket;
    mAudioFormat.mReserved           = 0;
    
    
    
    
    //Obtain a RemoteIO unit instance
    AudioComponentDescription acd;
    acd.componentType = kAudioUnitType_Output;
    acd.componentSubType = kAudioUnitSubType_RemoteIO;
    acd.componentFlags = 0;
    acd.componentFlagsMask = 0;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &acd);
    CheckError(AudioComponentInstanceNew(inputComponent, &mAudioUnit), "Couldn't new AudioComponent instance");
    
    //The Remote I/O unit, by default, has output enabled and input disabled
    //Enable input scope of input bus for recording.
    UInt32 enable = 1;
    UInt32 disable=0;
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Input,
                                    kInputBus,
                                    &enable,
                                    sizeof(enable))
               , "kAudioOutputUnitProperty_EnableIO::kAudioUnitScope_Input::kInputBus");
    
    //Apply format to output scope of input bus for recording.
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    kInputBus,
                                    &mAudioFormat,
                                    sizeof(mAudioFormat))
               , "kAudioUnitProperty_StreamFormat::kAudioUnitScope_Output::kInputBus");
    
    //Disable buffer allocation for recording(optional)
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioUnitProperty_ShouldAllocateBuffer,
                                    kAudioUnitScope_Output,
                                    kInputBus,
                                    &disable,
                                    sizeof(disable))
               , "kAudioUnitProperty_ShouldAllocateBuffer::kAudioUnitScope_Output::kInputBus");
    
    //Applying format to input scope of output bus for playing
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    kOutputBus,
                                    &mAudioFormat,
                                    sizeof(mAudioFormat)), "kAudioUnitProperty_StreamFormat::kAudioUnitScope_Input::kOutputBus");
    
    //AudioUnitInitialize
    CheckError(AudioUnitInitialize(mAudioUnit), "AudioUnitInitialize");
}
-(void)startToRecord{
    //Add a callback for recording
    AURenderCallbackStruct recorderStruct;
    recorderStruct.inputProc = recordCallback;
    recorderStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioOutputUnitProperty_SetInputCallback,
                                    kAudioUnitScope_Input,
                                    kInputBus,
                                    &recorderStruct,
                                    sizeof(recorderStruct))
               , "kAudioOutputUnitProperty_SetInputCallback::kAudioUnitScope_Input::kInputBus");
    //Remove a callback for playing
    AURenderCallbackStruct playStruct;
    playStruct.inputProc=0;
    playStruct.inputProcRefCon=0;
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    kOutputBus,
                                    &playStruct,
                                    sizeof(playStruct)), "kAudioUnitProperty_SetRenderCallback::kAudioUnitScope_Input::kOutputBus");
    
    //Create an audio file for recording
    NSString *destinationFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.caf"];
    CFURLRef destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    CheckError(ExtAudioFileCreateWithURL(destinationURL, kAudioFileCAFType, &mAudioFormat, NULL, kAudioFileFlags_EraseFile, &mAudioFileRef),"Couldn't create a file for writing");
    CFRelease(destinationURL);
    AudioOutputUnitStart(mAudioUnit);
}
-(void)stopToRecord{
    AudioOutputUnitStop(mAudioUnit);
    //Dispose the audio file
    CheckError(ExtAudioFileDispose(mAudioFileRef),"ExtAudioFileDispose failed");
}
-(void)startToPlay{
    //Remove the input callback
    AURenderCallbackStruct recorderStruct;
    recorderStruct.inputProc = 0;
    recorderStruct.inputProcRefCon = 0;
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioOutputUnitProperty_SetInputCallback,
                                    kAudioUnitScope_Input,
                                    kInputBus,
                                    &recorderStruct,
                                    sizeof(recorderStruct))
               , "kAudioOutputUnitProperty_SetInputCallback::kAudioUnitScope_Input::kInputBus");
    //Add a callback for playing
    AURenderCallbackStruct playStruct;
    playStruct.inputProc=playCallback;
    playStruct.inputProcRefCon=(__bridge void * _Nullable)(self);
    CheckError(AudioUnitSetProperty(mAudioUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    kOutputBus,
                                    &playStruct,
                                    sizeof(playStruct)), "kAudioUnitProperty_SetRenderCallback::kAudioUnitScope_Input::kOutputBus");
    inMemoryAudioFile=[[InMemoryAudioFile alloc] init];
    NSString *filepath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.caf"];
    [inMemoryAudioFile open:filepath];
    AudioOutputUnitStart(mAudioUnit);
}
-(void)stopToPlay{
    AudioOutputUnitStop(mAudioUnit);
//    [inMemoryAudioFile release],
    inMemoryAudioFile=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configAudio];
    
    UIButton *button1=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame=CGRectMake(100, 100, 80, 30);
    button1.tag=1;
    [button1 setTitle:@"开始录音" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame=CGRectMake(100, 200, 80, 30);
    button2.tag=2;
    [button2 setTitle:@"开始放音" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}
- (IBAction)touch:(id)sender {
    
    if (isRecording) {

        [self stopToRecord];

        printf("stop record\n");
    }else{

        [self startToRecord];

        printf("start  record\n");
    }
    isRecording=!isRecording;
    
}
- (IBAction)touchPlay:(id)sender {
    
    if (isPlaying) {

        [self stopToPlay];
  
        printf("stop play\n");
    }else{
       
        [self startToPlay];
     
        printf("start  play\n");
    }
    isPlaying=!isPlaying;
}
-(void)buttonAction:(UIButton *)button{
    if (button.tag==1) {
        UIButton *other=(UIButton *)[button.superview viewWithTag:2];
        if (isRecording) {
            other.enabled=YES;
            [self stopToRecord];
            [button setTitle:@"开始录音" forState:UIControlStateNormal];
            printf("stop record\n");
        }else{
            other.enabled=NO;
            [self startToRecord];
            [button setTitle:@"停止录音" forState:UIControlStateNormal];
            printf("start  record\n");
        }
        isRecording=!isRecording;
    }else if(button.tag==2){
        UIButton *other=(UIButton *)[button.superview viewWithTag:1];
        if (isPlaying) {
            other.enabled=YES;
            [self stopToPlay];
            [button setTitle:@"开始放音" forState:UIControlStateNormal];
            printf("stop play\n");
        }else{
            other.enabled=NO;
            [self startToPlay];
            [button setTitle:@"停止放音" forState:UIControlStateNormal];
            printf("start  play\n");
        }
        isPlaying=!isPlaying;
    }
}
- (void)dealloc{
    CheckError(AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListener, (__bridge void *)(self)),"couldn't remove a route change listener");
    AudioUnitUninitialize(mAudioUnit);
    if (inMemoryAudioFile!=nil) {
//        [inMemoryAudioFile release],
        inMemoryAudioFile=nil;
    }
//    [super dealloc];
}

@end