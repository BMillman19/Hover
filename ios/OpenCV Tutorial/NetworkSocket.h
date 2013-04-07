//
//  NetworkSocket
//  FBHack
//
//  Created by Brandon Millman on 10/5/12.
//  Copyright (c) 2012 Brandon Millman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkSocketDelegate <NSObject>

- (void)eventOccurred:(NSString *)event withPayload:(NSDictionary *)payload;

@end

@interface NetworkSocket : NSObject

+ (id)socketToAddress:(NSString *)address withPort:(NSInteger)port withChannel:(NSString *) channel withDelegate:(id<NetworkSocketDelegate>)delegate;

- (void)sendEvent:(NSString *)event withPayload:(NSDictionary *)payload;
- (void)close;

@property (nonatomic, weak) id<NetworkSocketDelegate> delegate;


@end


