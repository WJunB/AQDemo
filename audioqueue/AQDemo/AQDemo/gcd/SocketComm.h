//
//  SocketComm.h
//  MotionGraphs
//
//  Created by X-Lab on 1/17/14.
//
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"

#import <CoreLocation/CoreLocation.h>
#define SRV_CONNECTED 0
#define SRV_CONNECT_SUC 1
#define SRV_CONNECT_FAIL 2

@interface SocketComm : NSObject <GCDAsyncUdpSocketDelegate>{
    
    GCDAsyncUdpSocket *client;
    GCDAsyncUdpSocket *server;
    
}

@property (nonatomic, retain) GCDAsyncUdpSocket *client;
@property (nonatomic, retain) GCDAsyncUdpSocket *server;




- (id)startUdpSocket;
- (void) sendMsg:(NSData *)msg toHost:(NSString *)host port:(uint16_t)port;
- (void) stopUdpSocket;



@end
