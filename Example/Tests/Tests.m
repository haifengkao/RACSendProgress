//
//  RACSendProgressTests.m
//  RACSendProgressTests
//
//  Created by Hai Feng Kao on 06/05/2016.
//  Copyright (c) 2016 Hai Feng Kao. All rights reserved.
//

// https://github.com/kiwi-bdd/Kiwi

#import "RACSubject.h"
#import "KLRACSubscriber.h"
#import "RACSignal+KLProgressSubscriptions.h"

SPEC_BEGIN(InitialTests)

describe(@"send progress test", ^{

  //context(@"will fail", ^{

      //it(@"can do maths", ^{
          //[[@1 should] equal:@2];
      //});

      //it(@"can read", ^{
          //[[@"number" should] equal:@"string"];
      //});
    
      //it(@"will wait and fail", ^{
          //NSObject *object = [[NSObject alloc] init];
          //[[expectFutureValue(object) shouldEventually] receive:@selector(autoContentAccessingProxy)];
      //});
  //});

  context(@"will pass", ^{
    
      it(@"will send progress", ^{
        RACSubject* subject = [RACSubject subject];
        [subject subscribeProgress:^(float x) {
            [[@(x) should] equal:@(1.0)];
        } next:^(id x) {
        }];

        [subject sendProgress:1.0];
      });
    
      //it(@"can read", ^{
          //[[@"team" shouldNot] containString:@"I"];
      //});  
  });
  
});

SPEC_END

