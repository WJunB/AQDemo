//
//  udpsocket.h
//  remoteMedicalUDP
//
//  Created by jun on 16/1/25.
//  Copyright © 2016年 jun. All rights reserved.
//

#include <stdio.h>

#import <Foundation/Foundation.h>


#define MAXFRAME 200000
#define MAXCACHE 3
#define AUDIOMAXCACHE 3

@interface udpsocket : NSObject{
    @public
    
    NSString *userName;
    NSString *peerIp;
    uint16_t peerPort;
    BOOL isGetPeer;
    BOOL isPentrate;
    struct mysockaddr *peerAddr;
    unsigned int currentFrameID;
    bool ReadyGetData;
    struct VIDEO_CACHE *VArray;
    struct AUDIO_CACHE *AArray;
    Byte record[10000][2];
    dispatch_queue_t AudioSync;
    dispatch_queue_t VideoSync;
    NSMutableArray *AudioQueue;
    NSMutableArray *VideoQueue;
    bool hasBegin;
    dispatch_semaphore_t sempahore;
    dispatch_semaphore_t sempahoreend;
    int currentDataSize;
    bool start;
}



-(id)init;
-(void)SendPack:(NSData*) data isServer:(BOOL)flag;
-(void) SendUserinfoByName:(NSString*)username;
-(void) RecvPack:(NSData*)data;
-(void) DealWithRecvPack:(struct PT_MESSAGE*)data;
-(void) DealWithAVPack:(struct UDP_VIDEO_PACK *)data;
-(void) SendAudioByData:(NSData*)data frame_len:(int)frame_len frame_id:(int)frame_id;
-(void) SendVideoByData:(NSData*)data frame_len:(int)frame_len frame_id:(int)frame_id;



//-(void)dealloc;
//-(WORD) CalculateCRC:(struct NET_PACK*)data;
//-(void) Connect;
//-(void) SendPack:(struct NET_PACK *)data;

//


//-(void) ShutSocket;
//-(void) SendHeartBeat;
//-(void) StopTimer;
//-(void) SaveFile:(NSData*)data;
//-(BOOL) WriteFile:(struct FileInfo*)pFile file:(NSMutableArray*)file;
//-(void) SendFileByPath:(NSString*)filePath fileName:(NSString*)fileName type:(int)type;
//-(bool) SendFile_thread:(NSString*)filepath fileName:(NSString*)fileName type:(int)type;
//-(NSString*) Random_str;
//-(void) OnRecvControlMsg:(NSData*)msg;
//-(NSString*) GetFileNameDate:(NSString*)filename;
//-(void) HeartBeatTimeProc;
//-(void) Relogin:(NSString*)username;
//-(void) onDealwithReconnect:(NSData*)data;
//-(void) RegisterByData:(NSData*)data dlgType:(int)type;
//-(void) searchInfoByData:(NSData*) data tpye:(int)type;
//-(void) SendMsgByName:(NSString*)name message:(NSData*)msg;
//-(void) ReqRecordInfoByData:(NSData*)data recordType:(int)type;
//-(void) ReqDetailRecordInfoByData:(NSData*)data recordType:(int)type;
//-(void) ReqUserInfoByData:(NSData*)data;
//
//
//
//
//-(void) test;



@end




