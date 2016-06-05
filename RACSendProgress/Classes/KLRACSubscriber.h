
#import <Foundation/Foundation.h>
#import "RACSubscriber.h"

@class RACCompoundDisposable;

@interface NSObject (RACSendProgress)
- (void)rac_sendProgress:(float)p;
- (void)rac_setProgress:(void (^)(float))progressBlock;
- (void (^)(float))rac_progress;
@end


@interface KLRACSubscriber: NSObject<RACSubscriber>
@property(nonatomic,strong)id<RACSubscriber> subscriber;

+ (instancetype)subscriberWithNext:(void (^)(id x))next progress:(void (^)(float progress))progress error:(void (^)(NSError *error))error completed:(void (^)(void))completed;

- (void)sendNext:(id)value;
- (void)sendError:(NSError *)error;
- (void)sendCompleted;
- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable;

@end
