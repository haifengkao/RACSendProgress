#import "RACSignal+KLProgressSubscriptions.h"
#import "KLRACSubscriber.h"

@implementation RACSignal (KLProgressSubscriptions)

- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock {
    NSParameterAssert(progress != NULL);
    NSParameterAssert(nextBlock != NULL);
    
    KLRACSubscriber *o = [KLRACSubscriber subscriberWithNext:nextBlock progress:progress error:NULL completed:NULL];
    
    return [self subscribe:o];
}

- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock completed:(void (^)(void))completedBlock {
    NSParameterAssert(progress != NULL);
    NSParameterAssert(nextBlock != NULL);
    NSParameterAssert(completedBlock != NULL);
    
    KLRACSubscriber *o = [KLRACSubscriber subscriberWithNext:nextBlock progress:progress error:NULL completed:completedBlock];
    
    return [self subscribe:o];
}

- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock {
    NSParameterAssert(progress != NULL);
    NSParameterAssert(nextBlock != NULL);
    NSParameterAssert(errorBlock != NULL);
    NSParameterAssert(completedBlock != NULL);
    
    KLRACSubscriber *o = [KLRACSubscriber subscriberWithNext:nextBlock progress:progress error:errorBlock completed:completedBlock];
    
    return [self subscribe:o];
}

- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress completed:(void (^)(void))completedBlock {
    NSParameterAssert(progress != NULL);
    NSParameterAssert(completedBlock != NULL);
    
    KLRACSubscriber *o = [KLRACSubscriber subscriberWithNext:NULL progress:progress error:NULL completed:completedBlock];
    
    return [self subscribe:o];
}

- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock {
    NSParameterAssert(progress != NULL);
    NSParameterAssert(nextBlock != NULL);
    NSParameterAssert(errorBlock != NULL);
    
    KLRACSubscriber *o = [KLRACSubscriber subscriberWithNext:nextBlock progress:progress error:errorBlock completed:NULL];
    
    return [self subscribe:o];
}

- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock {
    NSParameterAssert(progress != NULL);
    NSParameterAssert(errorBlock != NULL);
    NSParameterAssert(completedBlock != NULL);
    
    KLRACSubscriber *o = [KLRACSubscriber subscriberWithNext:NULL progress:progress error:errorBlock completed:completedBlock];
    
    return [self subscribe:o];
}

@end
