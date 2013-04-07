//
//  NetworkSocket.m
//  FBHack
//
//  Created by Brandon Millman on 10/5/12.
//  Copyright (c) 2012 Brandon Millman. All rights reserved.
//

#import "NetworkSocket.h"
#import "SRWebSocket.h"
#import "JSONKit.h"
#import "SocketIO.h"

#define kBaseURL @"http://54.235.249.77"
#define kBasePort 8080


@interface NetworkSocket () <SocketIODelegate>

@property (nonatomic, strong) SocketIO *socket;
@property (nonatomic, strong) NSString *channel;

@end

@implementation NetworkSocket

@synthesize delegate = _delegate;
@synthesize socket = _socket;


#pragma mark - Class Factory Methods

+ (id)socketToAddress:(NSString *)address withPort:(NSInteger)port withChannel:(NSString *)channel withDelegate:(id<NetworkSocketDelegate>)delegate;
{
    NetworkSocket *socket = [[self alloc] initWithAddress:address withPort:port withChannel:channel];
    socket.delegate = delegate;
    
    return socket;
}

#pragma mark - Dealloc and Init

-(void)dealloc
{
    [_socket disconnect];
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port withChannel:(NSString *)channel
{
    if (self = [super init]) {
        self.channel = channel;
        
        _socket = [[SocketIO alloc] initWithDelegate:self];
        [_socket connectToHost:address onPort:port];
    }
    return self;
}

#pragma mark - Instance Methods

- (void)sendEvent:(NSString *)event withPayload:(NSDictionary *)payload
{
    NSMutableDictionary *mutableMessageDictionary = [NSMutableDictionary dictionaryWithDictionary:payload];
    [mutableMessageDictionary setObject:self.channel forKey:@"channel"];

    [_socket sendEvent:event withData:mutableMessageDictionary andAcknowledge:^(id argsData){NSLog(@"Message Success");}];
}

- (void)close
{
    if (_socket) {
        [_socket disconnect];
    }
}

#pragma mark - SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"Socket Opened!");
    [_socket sendEvent:@"join_channel" withData:self.channel];
    [self.delegate socketDidOpen];

}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    if (error) {
        [self.delegate socketDidFailWithError:error];
    } else {
        [self.delegate socketDidClose];
    }
}


- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{

}

- (void) socketIO:(SocketIO *)socket failedToConnectWithError:(NSError *)error
{
    NSLog(@"Socket error");
    NSLog(@"%@", error);
    [self.delegate socketDidFailWithError:error];
    _socket = nil;
}

@end
