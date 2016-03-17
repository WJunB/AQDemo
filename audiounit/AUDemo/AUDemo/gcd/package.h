//
//  package.h
//  udpdemo
//
//  Created by jun on 16/1/24.
//  Copyright © 2016年 jun. All rights reserved.
//

#ifndef package_h
#define package_h
#define UDP_REMOTE_PORT 4678
#define UDP_REMOTE_IP @"192.168.1.135"//@"192.168.1.118"//@"123.57.231.105"//@"192.168.8.217"//@"192.168.10.159"//
#define UDP_LOCAL_PORT 4687
#define UDP_LOCAL_IP @"192.168.8.83"

#include"string.h"
#import <netinet/in.h>
#import <Foundation/Foundation.h>


#define CHAR char
#define WORD unsigned short
#define DWORD unsigned long
#define __int64 __int64_t
#define INT int
#define ZeroMemory(Destination,Length) memset((Destination),0,(Length))



#define QUEUE_SIZE 1000
#define PORT	4678
#define MINSIZE	512
#define PACK_SIZE 512
#define BUFFERSIZE 100000
#define VIDEO_FLAG 9090
#define AUDIO_FLAG 9091


#define FOWARD_FLAG		8989
#define LOGIN_FLAG		8988
#define LOGOUT_FLAG		8987
#define ADDR_FLAG		8986
#define MAXPACKSIZE		530
#define MAXSIZE			1500


#define USERNAME_SIZE 10
#define PENTRATE	1003		//客户端发送请求，请求服务器让对方联系自己
#define HANDSHAKE	1004		//对方发送的试探信号
#define PANTRATEFAILED	1005		//穿透失败


#pragma pack (push)   //store alignment state
#pragma pack (1)

typedef struct UDP_VIDEO_PACK{
    unsigned short flag;      //add in 2015/4/12
    unsigned int frame_id;    //frame id
    unsigned short slice_id;   //every slice of frame
    unsigned short data_len;    //data_len
    unsigned int frame_len;    // the whole byte of slice
    unsigned char data[MINSIZE];
//    UDP_VIDEO_PACK(){
//        flag = 9090;
//        frame_id = 0;
//        slice_id = 0;
//        data_len = 0;
//        frame_len = 0;
//        memset(data, 0, MINSIZE);
//    }
    
}*LPUDP_VIDEO_PACK;



typedef struct VIDEO_CACHE{
    
    unsigned int frame_id;    //frame id
    unsigned char count;     //slice count
    unsigned char fullflag;  //is full
    unsigned int datalen;   // frame lenth
    unsigned char data[BUFFERSIZE];
//    VIDEO_CACHE(){
//        frame_id = 0;
//        count = 0;
//        fullflag = 0;
//        datalen = 0;
//        memset(data, 0, BUFFERSIZE);
//    }
//    void reset(){
//        frame_id = 0;
//        count = 0;
//        fullflag = 0;
//        datalen = 0;
//        memset(data, 0, BUFFERSIZE);
//    }
    
}*LPVIDEO_CACHE;

typedef struct UDP_AUDIO_PACK{
    
    unsigned short flag;      //音频标识符
    INT		m_nSize;
    INT		m_nSeque;
    INT		ID;
    CHAR	m_pcData[1024 * 5];
//    UDP_AUDIO_PACK() { Reset(); }
//    void Reset()
//    {
//        flag = AUDIO_FLAG;
//        ZeroMemory(m_pcData, sizeof(m_pcData));
//        ID = 0;
//        m_nSeque = 0;
//        m_nSize = 0;
//    }
    
}*LPUDP_AUDIO_PACK;

typedef struct AUDIO_CACHE{
    
    unsigned int frame_id;    //frame id
    unsigned char count;     //slice count
    unsigned char fullflag;  //is full
    unsigned int datalen;   // frame lenth
    unsigned char data[BUFFERSIZE];
    
//    AUDIO_CACHE(){
//        frame_id = 0;
//        memset(data, 0, BUFFERSIZE);
//        count = 0;
//        fullflag = 0;
//        datalen = 0;
//    }
//    void reset(){
//        frame_id = 0;
//        memset(data, 0, BUFFERSIZE);
//        count = 0;
//        fullflag = 0;
//        datalen = 0;
//    }
    
}*LPAUDIO_CACHE;

typedef struct pa_addr {
    union {
        struct { unsigned char s_b1, s_b2, s_b3, s_b4; } S_un_b;
        struct { unsigned short s_w1, s_w2; } S_un_w;
        unsigned long S_addr;
    } S_un;
#define s_addr  S_un.S_addr /* can be used for most tcp & ip code */
#define s_host  S_un.S_un_b.s_b2    // host on imp
#define s_net   S_un.S_un_b.s_b1    // network
#define s_imp   S_un.S_un_w.s_w2    // imp
#define s_impno S_un.S_un_b.s_b4    // imp #
#define s_lh    S_un.S_un_b.s_b3    // logical host
};

struct mysockaddr {
    short   sin_family;
    unsigned short sin_port;
    struct  pa_addr sin_addr;
    char    sin_zero[8];
};

typedef struct UDP_FORWARD_PACK{
    unsigned short flag;      //转发的flag
    struct mysockaddr addr;		//windows下可以使用，转换到unix下，需要解决long字型大小问题
    unsigned int len;
    unsigned char data[MAXPACKSIZE];//包内数据，真正的包数据
//    UDP_FORWARD_PACK(){
//        flag = FOWARD_FLAG;
//        len = 0;
//        memset(data, 0, MAXPACKSIZE);
//    }
}*LPUDP_FORWARD_PACK;

//LOGIN
typedef struct UDP_LOGIN_PACK{
    unsigned short flag;      //转发的flag
    unsigned int len;
    unsigned char name[MAXPACKSIZE];//包内数据，真正的包数据
//    UDP_LOGIN_PACK(){
//        flag = LOGIN_FLAG;
//        len = 0;
//        memset(name, 0, MAXPACKSIZE);
//    }
}*LPUDP_LOGIN_PACK;

//LOGOUT
typedef struct UDP_LOGOUT_PACK{
    unsigned short flag;      //转发的flag
    unsigned int len;
    unsigned char name[MAXPACKSIZE];//包内数据，真正的包数据
//    UDP_LOGOUT_PACK(){
//        flag = LOGOUT_FLAG;
//        len = 0;
//        memset(name, 0, MAXPACKSIZE);
//    }
}*LPUDP_LOGOUT_PACK;

//IP PORT信息
typedef struct UDP_ADDR_PACK{
    unsigned short flag;      //转发的flag
    struct mysockaddr   addr;
    unsigned int len;
    unsigned char name[MAXPACKSIZE];//包内数据，真正的包数据
//    UDP_ADDR_PACK(){
//        flag = ADDR_FLAG;
//        memset(&addr, 0, sizeof(addr));
//        len = 0;
//        memset(name, 0, MAXPACKSIZE);
//    }
}*LPUDP_ADDR_PACK;

/*
 客户端发送请求，请求服务器让对方联系自己的包结构
 必须包含，type，对方姓名
 */
typedef struct PT_MESSAGE{
    WORD type;
    char username[USERNAME_SIZE];
//    PT_MESSAGE(){
//        type = PENTRATE;
//        memset(username, 0, USERNAME_SIZE);
//    }
//    void strusername(char *name){
//        strcpy(username, name);
//    }
    
}*LPPT_MESSAGE;

/*将A的相关信息IP,PORT发送给B，通知B进行相关操作*/
typedef struct PT_REQUEST{
    //ip
    WORD type;
    char ip[16];
    unsigned short port;
    char username[USERNAME_SIZE];
//    PT_REQUEST(){
//        type = 0;
//        memset(ip, 0, 16);
//        port = 0;
//    }
    
}*LPPT_REQUEST;
#pragma pack (pop)    //retrive alignment state


@interface  AUDIO_CACHE_OBJECT: NSObject{
    unsigned int frame_id;    //frame id
    unsigned char count;     //slice count
    unsigned char fullflag;  //is full
    unsigned int datalen;   // frame lenth
    unsigned char *data;
}
-(unsigned int) Frame_id;
-(void) setFrame_id:(unsigned int)value;
-(unsigned int) count;
-(void) setCount:(unsigned int)value;
-(unsigned int) fullflag;
-(void) setFullflag:(unsigned int)value;
-(unsigned int) datalen;
-(void) setDatalen:(unsigned int)value;
-(unsigned char*) GetData;
-(void) AddData:(const unsigned char*)dataValue len:(unsigned int)len;
-(void) memset;
@end


@interface  VIDEO_CACHE_OBJECT: NSObject{
    unsigned int frame_id;    //frame id
    unsigned char count;     //slice count
    unsigned char fullflag;  //is full
    unsigned int datalen;   // frame lenth
    unsigned char* data;
}
-(unsigned int) Frame_id;
-(void) setFrame_id:(unsigned int)value;
-(unsigned int) count;
-(void) setCount:(unsigned int)value;
-(unsigned int) fullflag;
-(void) setFullflag:(unsigned int)value;
-(unsigned int) datalen;
-(void) setDatalen:(unsigned int)value;
-(unsigned char*) GetData;
-(void) AddData:(const unsigned char*)dataValue len:(unsigned int)len;
-(void) memset;
@end

#endif /* package_h */
