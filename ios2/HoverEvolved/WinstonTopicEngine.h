//
//  WinstonTopicEngine.h
//  Winston
//
//  Created by Brandon Millman on 12/12/12.
//  Copyright (c) 2012 Equinox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WinstonTopicEngineDelegate;

@interface WinstonTopicEngine : NSObject

- (void)start;
- (void)stop;

@property (nonatomic, assign) NSTimeInterval updateInterval;
@property (nonatomic, assign) id<WinstonTopicEngineDelegate> delegate;

@end

@protocol WinstonTopicEngineDelegate <NSObject>

@required
- (void)topicEngine:(WinstonTopicEngine *)engine didFindTopic:(NSString *)topic;

@optional
- (void)topicEngineDidStart:(WinstonTopicEngine *)engine;
- (void)topicEngine:(WinstonTopicEngine *)engine didFailWithError:(NSError *)error suggestion:(NSString *)suggestion;

@end
