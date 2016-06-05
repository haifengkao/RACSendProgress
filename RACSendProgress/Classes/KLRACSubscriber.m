#import "KLRACSubscriber.h"

#import "RACPassthroughSubscriber.h"
#import "RACDisposable.h"
#import <objc/runtime.h>

#import "RACPassthroughSubscriber.h"
@interface RACPassthroughSubscriber (KLProgress)
- (void)sendProgress:(float)p;
@end

@implementation RACPassthroughSubscriber(KLProgress)
- (void)sendProgress:(float)p{
    
    RACDisposable *disposable = [self performSelector:@selector(disposable)];
    if (disposable.disposed) return;
    
    id<RACSubscriber> innerSubscriber = [self valueForKey:@"innerSubscriber"];
    if([innerSubscriber isKindOfClass:[RACPassthroughSubscriber class]]){
        [(RACPassthroughSubscriber*)innerSubscriber sendProgress:p];
    }else if([innerSubscriber isKindOfClass:[KLRACSubscriber class]]){
        [(KLRACSubscriber*)innerSubscriber sendProgress:p];
    }else{
        NSAssert(0, @"not recognized object");
    }

}

@end



static NSString *KLProgress_Block_Key;
@interface KLRACSubscriber()

@property (nonatomic, copy) void (^_progress)(float progress);

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
        subscriber = [[KLRACSubscriber alloc]init];
        subscriber.subscriber = proxySubscriber;
        subscriber._progress = progress;
    }else{
        NSAssert(0, @"not create RACSubscriber");
    }
    
    return subscriber;

}

- (void)set_progress:(void (^)(float))_progress {
    objc_setAssociatedObject(self, &KLProgress_Block_Key, _progress, OBJC_ASSOCIATION_COPY);
}

- (void (^)(float))_progress {
    return objc_getAssociatedObject(self, &KLProgress_Block_Key);
}

- (void)sendProgress:(float)p {
    RACDisposable *disposable = [self performSelector:@selector(disposable)];   if(disposable.disposed) return;
    if (self._progress != NULL) self._progress(p);
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

- (void)dealloc{
    self.subscriber = nil;
}

@end


@implementation RACSubject (KLProgressSending)

- (void)sendProgress:(float)value {
    void (^subscriberBlock)(id<RACSubscriber> subscriber) = ^(id<RACSubscriber> subscriber){
        if([subscriber isKindOfClass:[RACPassthroughSubscriber class]]){
            [(RACPassthroughSubscriber*)subscriber sendProgress:value];
        }
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
}

@end

