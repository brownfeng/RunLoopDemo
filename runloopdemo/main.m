//
//  main.m
//  runloopdemo
//
//  Created by brownfeng on 16/7/4.
//  Copyright © 2016年 brownfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

static void _perform(void *info __unused) {
    printf("source0 callback!!!! \n \n");
}

static void _timer(CFRunLoopTimerRef timer __unused, void *info) {
    printf("timer callback!!!!! \n \n");
    CFRunLoopSourceSignal(info);
}

/**
 kCFRunLoopEntry = (1UL << 0),
 kCFRunLoopBeforeTimers = (1UL << 1),
 kCFRunLoopBeforeSources = (1UL << 2),
 kCFRunLoopBeforeWaiting = (1UL << 5),
 kCFRunLoopAfterWaiting = (1UL << 6),
 kCFRunLoopExit = (1UL << 7),
 kCFRunLoopAllActivities = 0x0FFFFFFFU
 */
static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    
    switch (activity) {
        case kCFRunLoopEntry:
            printf("kCFRunLoopEntry\n");
            break;
        case kCFRunLoopBeforeTimers:
            printf("kCFRunLoopBeforeTimers\n");
            break;
        case kCFRunLoopBeforeSources:
            printf("kCFRunLoopBeforeSources\n");
            break;
        case kCFRunLoopBeforeWaiting:
            printf("kCFRunLoopBeforeWaiting\n");
            printf("zzzzzzzzzzzzzz... \n   zzzzzzzzzzzz...\n");
            break;
        case kCFRunLoopAfterWaiting:
            printf("kCFRunLoopAfterWaiting\n");
            break;
        case kCFRunLoopExit:
            printf("kCFRunLoopExit\n");
            break;
        default:
            break;
    }
}
//  注册一个观察者,观察每一次 runloop 的开始和各种状态
//观察者需要一个回掉方法,犹豫这是 CoreFoundation,所以是 C 语言写的,你需要传递一个函数指针, 来当做观察者的回掉方法
static void _registerObserver() {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {0,NULL,NULL,NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                       kCFRunLoopAllActivities,
                                       YES,
                                       0,
                                       &runLoopObserverCallBack,
                                       &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
}




int main(int argc, const char * argv[]) {
    @autoreleasepool {
        _registerObserver();
        
        
        //source0
        CFRunLoopSourceRef source;
        CFRunLoopSourceContext source_context;
        bzero(&source_context, sizeof(source_context));
        source_context.perform = _perform;
        source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &source_context);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopCommonModes);
        
        // timer
        CFRunLoopTimerRef timer;
        CFRunLoopTimerContext timer_context;
        bzero(&timer_context, sizeof(timer_context));
        timer_context.info = source;
        timer = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent(), 1, 0, 0, _timer, &timer_context);
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
        
        CFRunLoopRun();
        
        
        NSLog(@"out ...");
    }
    return 0;
}

/**
 GCD Timer 和 NSTimer!!!!两者的区别
 
 功能是向main线程中加入两个input source，一个是timer，一个是自定义input source，然后这个timer中触发自定义source，于是调用其回调方法。 在这儿timer触发source来调用回调方法，显得有点多此一举。但是在多线程开发当中，这就很有用了，我们可以把这个自定义的source加入到子线程的runloop中，然后在主线程中触发source，这样在子线程中就可以调用回调方法了。  这样做的好久是什么呀？ 节约用电，因为runloop一般情况下是休眠的，只有事件触发的时候才开始工作。 这与windows下的waitforsingleobject有点类似， 与多线程中的信号量，事件也有些雷同。

 */

//int main(int argc, const char * argv[]) {
//    dispatch_source_t source, timer;
//    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
//    dispatch_source_set_event_handler(source, ^{
//        printf("hello\n");
//    });
//    dispatch_resume(source);
//    
//    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC, 0);
//    dispatch_source_set_event_handler(timer, ^{
//        dispatch_source_merge_data(source, 1);
//    });
//    
//    dispatch_resume(timer);
//    dispatch_main();
//}


