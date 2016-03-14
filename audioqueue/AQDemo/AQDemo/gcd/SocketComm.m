//
//  SocketDemoViewController.m
//  SocketDemo
//
//  Created by xiang xiva on 10-7-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SocketComm.h"
#import "udpsocket.h"
#import "package.h"

extern udpsocket *udp;
extern SocketComm *sock;

@implementation SocketComm

@synthesize client;
@synthesize server;





- (id)startUdpSocket
{
    dispatch_queue_t udpSocketQueue = dispatch_queue_create("com.xlab.udpSocketQueue", DISPATCH_QUEUE_CONCURRENT);
    self.server =[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:udpSocketQueue];
    self.client =[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:udpSocketQueue];
    
    NSError *error = nil;
    
    if (![self.server bindToPort:PORT error:&error])
    {
        NSLog(@"error starting server (bind):%@",error);
        return self;
    }

    
    if (![self.server beginReceiving:&error])
    {
        [sock.server close];
        NSLog(@"error starting server (recv):%@",error);
        return self;
    }
    [self.server setIPv4Enabled:YES];
    [self.server setIPv6Enabled:NO];
    NSLog(@"udp echo server started on port %hu",[self->server localPort]);
    return self;

}

- (void) stopUdpSocket{
    [self.server close];
}



-(void)dealloc{
    self.client = nil;
    self.server = nil;
}


- (void) sendMsg:(NSData *)msg toHost:(NSString *)host port:(uint16_t)port
{

    [sock.server sendData:msg toHost:host port:port withTimeout:-1 tag:0];
    

}


- (void) udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
 
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    [udp RecvPack:data];
}



- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{

}










@end