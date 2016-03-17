//
//  package.m
//  remoteMedicalUDP+AV
//
//  Created by jun on 16/3/4.
//  Copyright © 2016年 jun. All rights reserved.
//

#import "package.h"
@class AUDIO_CACHE_OBJECT;
@implementation AUDIO_CACHE_OBJECT

-(id) init{
    self = [super init];
    frame_id = 0;
    count = 0;
    fullflag = 0;
    datalen = 0;
    data = (unsigned char*)malloc(BUFFERSIZE+1);
    memset(data, 0, BUFFERSIZE+1);
    return self;
}
-(unsigned int) Frame_id                        { return frame_id;}
-(void) setFrame_id:(unsigned int)value         { frame_id = value;}
-(unsigned int) count                           { return count;}
-(void) setCount:(unsigned int)value            { count = value;}
-(unsigned int) fullflag                        { return fullflag;}
-(void) setFullflag:(unsigned int)value         { fullflag = value;}
-(unsigned int) datalen                         { return datalen;}
-(void) setDatalen:(unsigned int)value          { datalen = value;}
-(unsigned char*) GetData                                  { return data;}
-(void) AddData:(const unsigned char*) dataValue len:(unsigned int)len           { memcpy(data, dataValue, len);}
-(void) memset{
    frame_id = 0;
    count = 0;
    fullflag = 0;
    datalen = 0;
    memset(data, 0, BUFFERSIZE+1);
}
-(void) dealloc{
    free(data);

}
@end
@class VIDEO_CACHE_OBJECT;
@implementation VIDEO_CACHE_OBJECT

-(id) init{
    self = [super init];
    frame_id = 0;
    count = 0;
    fullflag = 0;
    datalen = 0;
    data = (unsigned char*)malloc(BUFFERSIZE+1);
    memset(data, 0, BUFFERSIZE+1);
    return self;
}
-(unsigned int) Frame_id                        { return frame_id;}
-(void) setFrame_id:(unsigned int)value         { frame_id = value;}
-(unsigned int) count                           { return count;}
-(void) setCount:(unsigned int)value            { count = value;}
-(unsigned int) fullflag                        { return fullflag;}
-(void) setFullflag:(unsigned int)value         { fullflag = value;}
-(unsigned int) datalen                         { return datalen;}
-(void) setDatalen:(unsigned int)value          { datalen = value;}
-(unsigned char*) GetData                                  { return data;}
-(void) AddData:(const unsigned char*)dataValue len:(unsigned int)len           { memcpy(data, dataValue, len);}
-(void) memset{
    frame_id = 0;
    count = 0;
    fullflag = 0;
    datalen = 0;
    memset(data, 0, BUFFERSIZE+1);
}
-(void) dealloc{
    free(data);

}
@end