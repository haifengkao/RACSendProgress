
#import <Foundation/Foundation.h>
#import "RACSignal.h"

@interface RACSignal (KLProgressSubscriptions)


// Convenience method to subscribe to the `progress` and `next` events.
- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock ;

// Convenience method to subscribe to the `progress`, `next` and `completed` events.
- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock completed:(void (^)(void))completedBlock;

// Convenience method to subscribe to the `progress`, `next`, `completed`, and `error` events.
- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock;


- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress completed:(void (^)(void))completedBlock;

// Convenience method to subscribe to `progress`, `next` and `error` events.
- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress next:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock;

// Convenience method to subscribe to `progress`, `error` and `completed` events.
- (RACDisposable *)subscribeProgress:(void (^)(float progress))progress error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock;

@end

