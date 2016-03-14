//
//  udpsocket.cpp
//  remoteMedicalUDP
//
//  Created by jun on 16/1/25.
//  Copyright © 2016年 jun. All rights reserved.
//

#include "udpsocket.h"
#import "SocketComm.h"
#import "package.h"
//#import "map"
#import "AQSController.h"

extern SocketComm *sock;

extern udpsocket *udp;
extern char *Gbuffer;


@implementation udpsocket


-(id) init{
    self = [super init];
    if (self !=nil) {
        NSLog(@"udpsocket is not nil");
        AudioSync = dispatch_queue_create("com.xlab.AudioSync", NULL);
        VideoSync = dispatch_queue_create("com.xlab.VideoSync", NULL);
        peerAddr = (struct mysockaddr*)malloc(sizeof(struct mysockaddr));
        currentFrameID = 0;
        sock = [[SocketComm alloc] startUdpSocket];
        isGetPeer = NO;
        isPentrate = NO;
        ReadyGetData = NO;
        VArray =     (struct VIDEO_CACHE *)malloc(sizeof(struct VIDEO_CACHE)*MAXCACHE);
        memset(VArray, 0, sizeof(struct VIDEO_CACHE)*MAXCACHE);
        AArray =     (struct AUDIO_CACHE *)malloc(sizeof(struct AUDIO_CACHE)*AUDIOMAXCACHE);
        memset(AArray, 0, sizeof(struct AUDIO_CACHE)*AUDIOMAXCACHE);
        AudioQueue = [[NSMutableArray alloc] initWithCapacity:QUEUE_SIZE];
        VideoQueue = [[NSMutableArray alloc] initWithCapacity:QUEUE_SIZE];
        hasBegin = NO;
        sempahore = dispatch_semaphore_create(0);
        sempahoreend = dispatch_semaphore_create(0);
        currentDataSize = 0;
        start = NO;

    }
//    AudioSync = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    VideoSync = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
       return self;
}
-(void)dealloc{
    AudioSync = nil;
    VideoSync = nil;
    free(peerAddr);
    sock = nil;
    free(VArray);
    free(AArray);
    AudioQueue = nil;
    VideoQueue = nil;

}

-(void)SendPack:(NSData*) data isServer:(BOOL)flag{
    //    if (socketcomm == nil) {
    //        [socketcomm reConnect];
    //    }
//    if (flag) {
//
//    }
//    else if (udp->isGetPeer){
//        [sock  sendMsg:data toHost:udp->peerIp port:udp->peerPort];
////                [sock  sendMsg:data toHost:udp->peerIp port:UDP_LOCAL_PORT];
//    }
//    else{
//        NSLog(@"对方服务器地址为空！");
//    }

    [sock  sendMsg:data toHost:UDP_REMOTE_IP port:UDP_REMOTE_PORT];
}

-(void) SendUserinfoByName:(NSString *)username{
    
    struct UDP_LOGIN_PACK *login = (struct UDP_LOGIN_PACK*)malloc(sizeof(struct UDP_LOGIN_PACK));
    ZeroMemory(login, sizeof(struct UDP_LOGIN_PACK));
    memcpy(login->name, [username UTF8String], [username length]);
    login->flag = LOGIN_FLAG;
    login->len = 100;
    NSData *mydata = [[NSData alloc]initWithBytes:login length:(sizeof(UDP_LOGIN_PACK))];
    free(login);
    [self SendPack:mydata isServer:YES];
    
}

-(void) RecvPack:(NSData *)data{
    const int size = [data length];
    char *charData = (char*)malloc(size*sizeof(char));
    [data getBytes:charData length:size];
    if (currentDataSize +size >50000) {
        memcpy(Gbuffer+currentDataSize, charData, 50000-currentDataSize);
        memcpy(Gbuffer, charData+50000-currentDataSize, size-50000+currentDataSize);
        currentDataSize = size-50000+currentDataSize;
    }
    memcpy(Gbuffer+currentDataSize, charData, size);
    
    
    if (currentDataSize>35000&&!start) {
        AQSController   *aqc2 =[AQSController alloc];

        [aqc2 replay];
        start = YES;
    }
    free(charData);
}

-(void) DealWithAVPack:(struct UDP_VIDEO_PACK *)data{
    NSData *tmp = [NSData dataWithBytes:data length:sizeof(struct UDP_VIDEO_PACK)];
    
    switch (data->flag) {
        case VIDEO_FLAG:{
            //deal video
            dispatch_sync(udp->VideoSync, ^{
                [udp OnRecvAudioByData:tmp];
            });

//            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:tmp forKey:@"Daudio"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginView" object:self userInfo:dataDict];
//            
            break;
        }
        case AUDIO_FLAG:{
            //deal audio
            dispatch_sync(udp->AudioSync, ^{
                [udp OnRecvAudioByData:tmp];
            });
//            [udp OnRecvAudioByData:tmp];
//            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:tmp forKey:@"Dvideo"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginView" object:self userInfo:dataDict];
            
            break;
        }
    }

}

-(void) DealWithRecvPack:(struct PT_MESSAGE*)data{
    
    NSData *tmp = [NSData dataWithBytes:data length:sizeof(struct PT_MESSAGE)];
    
    switch (data->type) {
        case LOGIN_FLAG:{
            //deal login

            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:tmp forKey:@"login"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginView" object:self userInfo:dataDict];

            break;
        }
        case ADDR_FLAG:{
            //deal login
     
            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:tmp forKey:@"addr"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginView" object:self userInfo:dataDict];

            break;
        }
        case HANDSHAKE:{
            //deal login
            isGetPeer = YES;
            ReadyGetData = YES;
            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:tmp forKey:@"handshake"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginView" object:self userInfo:dataDict];
            //            [self.totle OnDealwithLogin:tmp];
            break;
        }
        case PENTRATE:{
            //deal login
            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:tmp forKey:@"pentrate"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginView" object:self userInfo:dataDict];
            //            [self.totle OnDealwithLogin:tmp];
            break;
        }
        case PANTRATEFAILED:{
            //deal login
            ReadyGetData = YES;
            NSDictionary *dataDict = [NSDictionary dictionaryWithObject:tmp forKey:@"pentratefailed"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginView" object:self userInfo:dataDict];
            //            [self.totle OnDealwithLogin:tmp];
            break;
        }
        
    }
}


-(void)OnRecvAudioByData:(NSData*)data{
    struct UDP_VIDEO_PACK *pack = (struct UDP_VIDEO_PACK*)malloc(sizeof(struct UDP_VIDEO_PACK));
    [data getBytes:pack length:sizeof(struct UDP_VIDEO_PACK)];
    if (pack->frame_len<=0 || pack->data_len<=0){
        free(pack);
        return;
    }

    int frameid = (pack->frame_id + MAXFRAME - udp->currentFrameID) % MAXFRAME;
//    static int countnum = 0;
    if (frameid <0) {
//        drop
//        printf("------------------------------------------drop,%d,%d\n", pack->frame_id, pack->frame_len);
//        printf("current,frame %d, drop frame %d\n", udp->currentFrameID, pack->frame_id);
//        return;
        
    }else if (frameid < AUDIOMAXCACHE){
//        copy
        // the buff is NULL, alloc it
        
        if (AArray[pack->frame_id % AUDIOMAXCACHE].datalen == 0){//数据为空，该帧到来的第一个包
            if (pack->frame_len >0){
                AArray[pack->frame_id % AUDIOMAXCACHE].datalen = pack->frame_len;
            }
            else
            {
                free(pack);
                return;
            }
        }
        //将数据copy进缓存
        memcpy(AArray[pack->frame_id % AUDIOMAXCACHE].data + pack->slice_id * PACK_SIZE, pack->data, pack->data_len);
        
        //        if (countnum<10000){
        //            record[countnum][0] = pack->frame_id;
        //            record[countnum][1] = pack->slice_id;
        //            countnum++;
        //        }
        AArray[pack->frame_id % AUDIOMAXCACHE].count++;
        int numpack;
        if (pack->frame_len%PACK_SIZE == 0) {
            numpack = pack->frame_len/PACK_SIZE;
        }else{
            numpack = pack->frame_len/PACK_SIZE +1;
        }
        
        //判断当前frame是否满了
        if (numpack == AArray[pack->frame_id % AUDIOMAXCACHE].count){//full
            AArray[pack->frame_id % AUDIOMAXCACHE].fullflag = 1;
//            printf("full--------------%d\n", pack->frame_id);
            
        }
        else{
            free(pack);
            return;
        }
        
    }else if (frameid <2*AUDIOMAXCACHE){
//        input while then copy
        while (frameid >= AUDIOMAXCACHE){
            //deal with the frame without considering the fufill event
            //todo
//            printf("%d frame\n", pack->frame_id);
            if(AArray[udp->currentFrameID % AUDIOMAXCACHE].datalen >0)
            {
                AUDIO_CACHE_OBJECT *point = [[AUDIO_CACHE_OBJECT alloc]init];
                [point setFrame_id:AArray[udp->currentFrameID % AUDIOMAXCACHE].frame_id];
                [point setCount:AArray[udp->currentFrameID % AUDIOMAXCACHE].count];
                [point setFullflag:AArray[udp->currentFrameID % AUDIOMAXCACHE].fullflag];
                [point setDatalen:AArray[udp->currentFrameID % AUDIOMAXCACHE].datalen];
                [point AddData:AArray[udp->currentFrameID % AUDIOMAXCACHE].data len:AArray[udp->currentFrameID % AUDIOMAXCACHE].datalen];
    //            @synchronized(udp->AudioQueue) {
                    [udp->AudioQueue addObject:point];
    //                NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"frame_id" ascending:YES];
    //                [udp->AudioQueue sortUsingDescriptors:[NSMutableArray arrayWithObject:sortDes]];
    //            }
                
                if (!AArray[udp->currentFrameID % AUDIOMAXCACHE].fullflag){
                    printf("没满%d\n", udp->currentFrameID);
                }
                
                memset(&AArray[udp->currentFrameID % AUDIOMAXCACHE],0,sizeof(struct VIDEO_CACHE));
            }
            udp->currentFrameID = (udp->currentFrameID + 1) % MAXFRAME;
            frameid = (pack->frame_id + MAXFRAME - udp->currentFrameID) % MAXFRAME;
        }
        // alloc the buffer
        if (pack->frame_len >0){
            AArray[pack->frame_id % AUDIOMAXCACHE].datalen = pack->frame_len;
        }
        else
        {
            free(pack);
            return;
        }
        
        memcpy(AArray[pack->frame_id % AUDIOMAXCACHE].data + pack->slice_id * PACK_SIZE, pack->data, pack->data_len);
        
        //        if (countnum<10000){
        //            record[countnum][0] = pack->frame_id;
        //            record[countnum][1] = pack->slice_id;
        //            countnum++;
        //        }
        
        AArray[pack->frame_id % AUDIOMAXCACHE].count++;
        
        int numpack1;
        if (pack->frame_len%PACK_SIZE == 0) {
            numpack1 = pack->frame_len/PACK_SIZE;
        }else{
            numpack1 = pack->frame_len/PACK_SIZE +1;
        }
        if (numpack1 == AArray[pack->frame_id % AUDIOMAXCACHE].count){//full
            AArray[pack->frame_id % AUDIOMAXCACHE].fullflag = 1;
        }
        else{
            free(pack);
            return;
        }
        
    }else{
//        input all then set udp->currentFrameID then copy
        if (pack->frame_len <=0){
            free(pack);
            return;
        }
        for (int i = 0; i<AUDIOMAXCACHE; i++) {
            //deal with the frame without considering the fufill event
            //todo
//            printf("%d frame\n", pack->frame_id);
            if(AArray[udp->currentFrameID % AUDIOMAXCACHE].datalen >0)
            {
                AUDIO_CACHE_OBJECT *point = [[AUDIO_CACHE_OBJECT alloc]init];
                [point setFrame_id:AArray[udp->currentFrameID % AUDIOMAXCACHE].frame_id];
                [point setCount:AArray[udp->currentFrameID % AUDIOMAXCACHE].count];
                [point setFullflag:AArray[udp->currentFrameID % AUDIOMAXCACHE].fullflag];
                [point setDatalen:AArray[udp->currentFrameID % AUDIOMAXCACHE].datalen];
                [point AddData:AArray[udp->currentFrameID % AUDIOMAXCACHE].data len:AArray[udp->currentFrameID % AUDIOMAXCACHE].datalen];
    //            @synchronized(udp->AudioQueue) {
                    [udp->AudioQueue addObject:point];
    //                NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"frame_id" ascending:YES];
    //                [udp->AudioQueue sortUsingDescriptors:[NSMutableArray arrayWithObject:sortDes]];
    ////            }
                
                if (!AArray[udp->currentFrameID % AUDIOMAXCACHE].fullflag){
                    printf("没满%d\n", udp->currentFrameID);
                }
                
                memset(&AArray[udp->currentFrameID % AUDIOMAXCACHE],0,sizeof(struct VIDEO_CACHE));
            }
            udp->currentFrameID = (udp->currentFrameID + 1) % MAXFRAME;
            frameid = (pack->frame_id + MAXFRAME - udp->currentFrameID) % MAXFRAME;
        }
        
          // alloc the buffer
        if (pack->frame_len >0){
            AArray[pack->frame_id % AUDIOMAXCACHE].datalen = pack->frame_len;
        }
        else
        {
            free(pack);
            return;
        }
        udp->currentFrameID = pack->frame_id;
        memcpy(AArray[pack->frame_id % AUDIOMAXCACHE].data + pack->slice_id * PACK_SIZE, pack->data, pack->data_len);

        AArray[pack->frame_id % AUDIOMAXCACHE].count++;
        
        int numpack1;
        if (pack->frame_len%PACK_SIZE == 0) {
            numpack1 = pack->frame_len/PACK_SIZE;
        }else{
            numpack1 = pack->frame_len/PACK_SIZE +1;
        }
        if (numpack1 == AArray[pack->frame_id % AUDIOMAXCACHE].count){//full
            AArray[pack->frame_id % AUDIOMAXCACHE].fullflag = 1;
        }
        else{
            free(pack);
            return;
        }
    }
    // deal with the current frame
//    printf("todo here %d\n", udp->currentFrameID);
    
    
    
    
    if (AArray[udp->currentFrameID % AUDIOMAXCACHE].fullflag == 1){
        //pop this frame
        //todo
//        printf("-----%d frame\n", pack->frame_id);
        if(AArray[udp->currentFrameID % AUDIOMAXCACHE].datalen >0)
        {
            AUDIO_CACHE_OBJECT *point = [[AUDIO_CACHE_OBJECT alloc]init];
            [point setFrame_id:AArray[pack->frame_id % AUDIOMAXCACHE].frame_id];
            [point setCount:AArray[pack->frame_id % AUDIOMAXCACHE].count];
            [point setFullflag:AArray[pack->frame_id % AUDIOMAXCACHE].fullflag];
            [point setDatalen:AArray[pack->frame_id % AUDIOMAXCACHE].datalen];
            [point AddData:AArray[pack->frame_id % AUDIOMAXCACHE].data len:AArray[pack->frame_id % AUDIOMAXCACHE].datalen];
    //        @synchronized(udp->AudioQueue) {

                [udp->AudioQueue addObject:point];
    //            NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"frame_id" ascending:YES];
    //            [udp->AudioQueue sortUsingDescriptors:[NSMutableArray arrayWithObject:sortDes]];
    //        }

            memset(&AArray[udp->currentFrameID % AUDIOMAXCACHE],0,sizeof(struct AUDIO_CACHE));
        }
        udp->currentFrameID = (udp->currentFrameID + 1) % MAXFRAME;
//        printf("-----%d frame is add queue\n",udp->currentFrameID);
    }
//    if (udp->currentFrameID>=1 && !hasBegin) {
////        [self performSelectorOnMainThread:@selector(audioPlay) withObject:nil waitUntilDone:NO];
//        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(audioPlay) object:nil];
//        [thread start];
//        hasBegin = YES;
//    }
    if ([udp->AudioQueue count] >3*AUDIOMAXCACHE) {
        dispatch_semaphore_signal(udp->sempahore);
//        dispatch_semaphore_wait(udp->sempahoreend,DISPATCH_TIME_FOREVER);
    }
    NSLog(@"audioqueue-----%d",[udp->AudioQueue count]);
    free(pack);
    return;
    
    
}
//-(void) audioPlay{
//    AQSController *AQS = [AQSController alloc];
//    [AQS replay];
//}
/*
-(void)OnRecvVideoByData:(NSData*)data{
    
    struct UDP_VIDEO_PACK pack = *(struct UDP_VIDEO_PACK*)malloc(sizeof(struct UDP_VIDEO_PACK));
    [data getBytes:pack length:sizeof(struct UDP_VIDEO_PACK)];
    
    int frameid = (pack.frame_id + MAXFRAME - udp->currentFrameID) % MAXFRAME;
    static int countnum = 0;
    if (frameid < MAXCACHE){//in B
        // the buff is NULL, alloc it
        
        if (VArray[pack.frame_id % MAXCACHE].datalen == 0){//数据为空，该帧到来的第一个包
            if (pack.frame_len >0){
                VArray[pack.frame_id % MAXCACHE].datalen = pack.frame_len;
            }
            else
                return;
        }
        //将数据copy进缓存
        memcpy(VArray[pack.frame_id % MAXCACHE].data + pack.slice_id * PACK_SIZE, pack.data, pack.data_len);
        
        if (countnum<10000){
            record[countnum][0] = pack.frame_id;
            record[countnum][1] = pack.slice_id;
            countnum++;
        }
        VArray[pack.frame_id % MAXCACHE].count++;
        int numpack;
        if (pack.frame_len%PACK_SIZE == 0) {
            numpack = pack.frame_len/PACK_SIZE;
        }else{
            numpack = pack.frame_len/PACK_SIZE +1;
        }
        
        //判断当前frame是否满了
        if (numpack == VArray[pack.frame_id % MAXCACHE].count){//full
            VArray[pack.frame_id % MAXCACHE].fullflag = 1;
            printf("full--------------%d\n", pack.frame_id);
        }
        else{
            return;
        }
    }
    else if (frameid < 2 * MAXCACHE){//in C
        while (frameid >= MAXCACHE){
            //deal with the frame without considering the fufill event
            //todo
            printf("%d frame\n", pack.frame_id);
            //            this->func(array[udp->currentFrameID % MAXCACHE].data, array[udp->currentFrameID % MAXCACHE].datalen);
            NSData *mydata = [[NSData alloc]initWithBytes:VArray[udp->currentFrameID % MAXCACHE].data length:(VArray[udp->currentFrameID % MAXCACHE].datalen)];
            @synchronized(udp->AudioQueue) {
                [udp->AudioQueue addObject:mydata];
            }
            if (!VArray[udp->currentFrameID % MAXCACHE].fullflag){
                printf("没满%d\n", udp->currentFrameID);
            }
            memset(&VArray[udp->currentFrameID % MAXCACHE],0,sizeof(struct VIDEO_CACHE));
            
            udp->currentFrameID = (udp->currentFrameID + 1) % MAXFRAME;
            frameid = (pack.frame_id + MAXFRAME - udp->currentFrameID) % MAXFRAME;
        }
        // alloc the buffer
        if (pack.frame_len >0){
            VArray[pack.frame_id % MAXCACHE].datalen = pack.frame_len;
        }
        else
            return;
        memcpy(VArray[pack.frame_id % MAXCACHE].data + pack.slice_id * PACK_SIZE, pack.data, pack.data_len);
        
        if (countnum<10000){
            record[countnum][0] = pack.frame_id;
            record[countnum][1] = pack.slice_id;
            countnum++;
        }
        
        VArray[pack.frame_id % MAXCACHE].count++;
        
        int numpack1;
        if (pack.frame_len%PACK_SIZE == 0) {
            numpack1 = pack.frame_len/PACK_SIZE;
        }else{
            numpack1 = pack.frame_len/PACK_SIZE +1;
        }
        if (numpack1 == VArray[pack.frame_id % MAXCACHE].count){//full
            VArray[pack.frame_id % MAXCACHE].fullflag = 1;
        }
        else{
            return;
        }
        
    }
    else{// in A
        //drop it
        printf("------------------------------------------drop,%d,%d\n", pack.frame_id, pack.frame_len);
        printf("current,frame %d, drop frame %d\n", udp->currentFrameID, pack.frame_id);
        return;
    }
    // deal with the current frame
    printf("todo here %d\n", udp->currentFrameID);
    if (VArray[udp->currentFrameID % MAXCACHE].fullflag == 1){
        //pop this frame
        //todo
        printf("-----%d frame\n", pack.frame_id);
        NSData *mydata = [[NSData alloc]initWithBytes:VArray[udp->currentFrameID % MAXCACHE].data length:(VArray[udp->currentFrameID % MAXCACHE].datalen)];
        //        id storeData = [[NSData alloc] initWithData:];
        @synchronized(udp->AudioQueue) {
            [udp->AudioQueue addObject:mydata];
        }
        //        this->func(VArray[udp->currentFrameID % MAXCACHE].data, VArray[udp->currentFrameID % MAXCACHE].datalen);
        if (!VArray[udp->currentFrameID % MAXCACHE].fullflag){
            //printf("没满%d\n", udp->currentFrameID);
            return;
        }
        
        memset(&VArray[udp->currentFrameID % MAXCACHE],0,sizeof(struct VIDEO_CACHE));
        
        udp->currentFrameID = (udp->currentFrameID + 1) % MAXFRAME;
        
    }
    
    
}
 */
-(void) SendAudioByData:(NSData*)data frame_len:(int)frame_len frame_id:(int)frame_id{
//    NSDictionary *dict = nil;
//    dict = [NSKeyedUnarchiver unarchiveObjectWithData:archData];
//    NSData *data = [dict objectForKey:@"data"];
//    UInt32 frame_id = [[dict objectForKey:@"frame_id"] unsignedIntegerValue];
//    UInt32 frame_len = [[dict objectForKey:@"frame_len"] unsignedIntegerValue];
    
    struct UDP_VIDEO_PACK *pack = (struct UDP_VIDEO_PACK*)malloc(sizeof(struct UDP_VIDEO_PACK));
    pack->frame_id =frame_id;
    pack->frame_len = frame_len;
    pack->flag = AUDIO_FLAG;
    
    DWORD size = [data length];
    char *file = (char *)malloc(size*sizeof(char));
    memset(file, 0, size);
    memcpy(file, [data bytes], size);
//    file = (char *)[data bytes];
    
    int i;
    DWORD numpack;
    if (size%PACK_SIZE == 0) {
        numpack = size/PACK_SIZE;
    }else{
        numpack = size/PACK_SIZE +1;
    }
    
    
    for (i = 0; i < numpack; i++)
    {
        pack->slice_id =i;
        memset(pack->data, 0, PACK_SIZE);
        if (i==numpack-1) {
            memcpy(pack->data, file + i*PACK_SIZE, size - PACK_SIZE*(numpack - 1));
            pack->data_len = size%PACK_SIZE;
            
        }
        else{
            memcpy(pack->data, file + i*PACK_SIZE, PACK_SIZE);
            pack->data_len = PACK_SIZE;
        }
        
        //文件写入
        if(isPentrate){
            NSData *mydata = [[NSData alloc]initWithBytes:pack length:(sizeof(struct UDP_VIDEO_PACK))];
            [udp SendPack:mydata isServer:!isPentrate];
        }
        else{
            struct UDP_FORWARD_PACK *fpack = (struct UDP_FORWARD_PACK*)malloc(sizeof(struct UDP_FORWARD_PACK));
            ZeroMemory(fpack, sizeof(struct UDP_FORWARD_PACK));
            fpack->flag = FOWARD_FLAG;
            memcpy(&fpack->addr, peerAddr, sizeof(struct mysockaddr));
            memcpy(fpack->data, pack, sizeof(struct UDP_VIDEO_PACK));
            
            fpack->len = sizeof(struct UDP_FORWARD_PACK);
            NSData *mydata = [[NSData alloc]initWithBytes:fpack length:(sizeof(struct UDP_FORWARD_PACK))];
            free(fpack);
            
            [udp SendPack:mydata isServer:!isPentrate];
        }
        
        
    }
    free(file);
    free(pack);
}

- (void) SendVideoByData:(NSData*)data frame_len:(int)frame_len frame_id:(int)frame_id{
//    NSDictionary *dict = nil;
//    dict = [NSKeyedUnarchiver unarchiveObjectWithData:archData];
//    NSData *data = [dict objectForKey:@"data"];
//    UInt32 frame_id = [[dict objectForKey:@"frame_id"] unsignedIntegerValue];
//    UInt32 frame_len = [[dict objectForKey:@"frame_len"] unsignedIntegerValue];
    
    struct UDP_VIDEO_PACK *pack = (struct UDP_VIDEO_PACK*)malloc(sizeof(struct UDP_VIDEO_PACK));
    pack->frame_id =frame_id;
    pack->frame_len = frame_len;
    pack->flag = VIDEO_FLAG;
    
    DWORD size = [data length];
    char *file = (char *)malloc(size*sizeof(char));
    memset(file, 0, size*sizeof(char));
    memcpy(file, [data bytes], size);
    int i;
    DWORD numpack;
    if (size%PACK_SIZE == 0) {
        numpack = size/PACK_SIZE;
    }else{
        numpack = size/PACK_SIZE +1;
    }
    
    
    for (i = 0; i < numpack; i++)
    {
        pack->slice_id =i;
        memset(pack->data, 0, PACK_SIZE);
        if (i==numpack-1) {
            memcpy(pack->data, file + i*PACK_SIZE, size - PACK_SIZE*(numpack - 1));
            pack->data_len = size%PACK_SIZE;
            
        }
        else{
            memcpy(pack->data, file + i*PACK_SIZE, PACK_SIZE);
            pack->data_len = PACK_SIZE;
        }
        
        //文件写入
        if(isPentrate){
            NSData *mydata = [[NSData alloc]initWithBytes:pack length:(sizeof(struct UDP_VIDEO_PACK))];
            [udp SendPack:mydata isServer:!isPentrate];
        }
        else{
            struct UDP_FORWARD_PACK *fpack = (struct UDP_FORWARD_PACK*)malloc(sizeof(struct UDP_FORWARD_PACK));
            ZeroMemory(fpack, sizeof(struct UDP_FORWARD_PACK));
            fpack->flag = FOWARD_FLAG;
            memcpy(&fpack->addr, peerAddr, sizeof(struct mysockaddr));
            memcpy(fpack->data, pack, sizeof(struct UDP_VIDEO_PACK));
            
            fpack->len = sizeof(struct UDP_FORWARD_PACK);
            NSData *mydata = [[NSData alloc]initWithBytes:fpack length:(sizeof(struct UDP_FORWARD_PACK))];
            free(fpack);

            [udp SendPack:mydata isServer:!isPentrate];
        }
        
        
    }
    free(pack);
    free(file);
    return;
}


@end

