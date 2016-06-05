#import "KLRACSubscriber.h"

#import "RACPassthroughSubscriber.h"
#import "RACDisposable.h"
#import "RACSubject.h"
#import <objc/runtime.h>

#import "RACPassthroughSubscriber.h"

static NSString *KLProgress_Block_Key;

@implementation NSObject (RACSendProgress)
- (void)rac_setProgress:(void (^)(float))_progress {
    objc_setAssociatedObject(self, &KLProgress_Block_Key, _progress, OBJC_ASSOCIATION_COPY);
}

- (void (^)(float))rac_progress {
    return objc_getAssociatedObject(self, &KLProgress_Block_Key);
}

- (void)rac_sendProgress:(float)p
{
    if (![self conformsToProtocol:@protocol(RACSubscriber)]) {
        NSAssert(NO, @"RACSubscriber only");
        return;
    }

    if ([self isKindOfClass:[RACPassthroughSubscriber class]]) {
        RACDisposable *disposable = [self performSelector:@selector(disposable)];
        if (disposable.disposed) return;
        NSObject<RACSubscriber>* innerSubscriber = [self valueForKey:@"innerSubscriber"];
        [innerSubscriber rac_sendProgress:p];
    } else if ([self isKindOfClass:[KLRACSubscriber class]]) {
        RACDisposable *disposable = [self performSelector:@selector(disposable)];   
        if(!disposable.disposed) {
            @synchronized (self) {
                void (^progressBlock)(float) = [self.rac_progress copy];
                if (progressBlock) { progressBlock(p); }
            }
        }
    } else if ([self isKindOfClass:[RACSubject class]]) {
        
        void (^subscriberBlock)(id<RACSubscriber> subscriber) = ^(id<RACSubscriber> subscriber){
            [(NSObject*)subscriber rac_sendProgress:p];
        };
        
        SEL performBlockSel = sel_registerName("enumerateSubscribersUsingBlock:");
        if([self respondsToSelector:performBlockSel]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:performBlockSel withObject:subscriberBlock];
#pragma clang diagnostic pop
        }else{
            NSAssert(0, @"not found enumerateSubscribersUsingBlock:");
        }
    } else {

        Class subscriberCls = NSClassFromString(@"RACSubscriber");
        if (subscriberCls && [self isKindOfClass:subscriberCls]) {
            @synchronized (self) {
                void (^progressBlock)(float) = [self.rac_progress copy];
                if (progressBlock) { progressBlock(p); }
            }
        } else {
            NSAssert(NO, @"not recognized subscriber object");
        }
    }
}
@end

@implementation KLRACSubscriber

+ (instancetype)subscriberWithNext:(void (^)(id x))next progress:(void (^)(float progress))progress error:(void (^)(NSError *error))error completed:(void (^)(void))completed {
    Class subscriberCls = NSClassFromString(@"RACSubscriber");
    SEL createSel = sel_registerName("subscriberWithNext:error:completed:");
    static int supportCreate = -1;
    id<RACSubscriber> proxySubscriber = nil;
    void *obj = nil;
    if(-1 == supportCreate){
        supportCreate = [subscriberCls respondsToSelector:createSel];
    }

    if(YES == supportCreate){
        NSMethodSignature *sig= [subscriberCls methodSignatureForSelector:createSel];
        if(sig && !strcmp(sig.methodReturnType, @encode(id))){
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
            [invocation setTarget:subscriberCls];
            [invocation setSelector:createSel];
            
            next = [next copy];
            error = [error copy];
            completed = [completed copy];
            
            [invocation setArgument:&next atIndex: 2];
            [invocation setArgument:&error atIndex: 3];
            [invocation setArgument:&completed atIndex: 4];
            [invocation retainArguments];
            
            [invocation invoke];
            
            [invocation getReturnValue:&obj];
            proxySubscriber = (__bridge id<RACSubscriber>)(obj);
        }
    }
    KLRACSubscriber *subscriber = nil;
    if(proxySubscriber){
        subscriber = [[KLRACSubscriber alloc] init];
        subscriber.subscriber = proxySubscriber;
        [subscriber rac_setProgress:progress];
    }else{
        NSAssert(0, @"not create RACSubscriber");
    }
    
    return subscriber;

}

- (void)sendNext:(id)value{
    return [self.subscriber sendNext:value];
}

- (void)sendError:(NSError *)error{
    return [self.subscriber sendError:error];
}

- (void)sendCompleted{
    return [self.subscriber sendCompleted];
}

- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable{
    [self.subscriber didSubscribeWithDisposable:disposable];
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    NSAssert(self.subscriber, @"subscriber is nil");
    //if(!self.subscriber)
        //KLLogError(@"subscriber is nil");
    [invocation invokeWithTarget:self.subscriber];
}
                                   
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    NSAssert(self.subscriber, @"subscriber is nil");
    //if(!self.subscriber)
        //KLLogError(@"subscriber is nil:%@",NSStringFromSelector(sel));
    NSObject* tmpSub = self.subscriber;
    return [tmpSub methodSignatureForSelector:sel];
}
@end
