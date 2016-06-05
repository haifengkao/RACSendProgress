
#import <Foundation/Foundation.h>
#import "RACSubscriber.h"

@class RACCompoundDisposable;

@interface KLRACSubscriber: NSObject<RACSubscriber>
@property(nonatomic,strong)id<RACSubscriber> subscriber;

+ (instancetype)subscriberWithNext:(void (^)(id x))next progress:(void (^)(float progress))progress error:(void (^)(NSError *error))error completed:(void (^)(void))completed;

- (void)sendProgress:(float)p;
- (void)sendNext:(id)value;
- (void)sendError:(NSError *)error;
- (void)sendCompleted;
- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable;

@end

#import "RACSubject.h"
@interface RACSubject (KLProgressSending)

- (void)sendProgress:(float)value;

@end

