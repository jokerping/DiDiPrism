//
//  UIScreenEdgePanGestureRecognizer+PrismIntercept.m
//  DiDiPrism
//
//  Created by hulk on 2019/10/15.
//

#import "UIScreenEdgePanGestureRecognizer+PrismIntercept.h"
// Dispatcher
#import "PrismEventDispatcher.h"
// Util
#import "PrismRuntimeUtil.h"

// 响应链信息 +  gesture.edges = UIRectEdgeLeft;

@implementation UIScreenEdgePanGestureRecognizer (PrismIntercept)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(initWithTarget:action:) swizzledSelector:@selector(prism_AutoDot_initWithTarget:action:)];
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(addTarget:action:) swizzledSelector:@selector(prism_AutoDot_addTarget:action:)];
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(removeTarget:action:) swizzledSelector:@selector(prism_AutoDot_removeTarget:action:)];
    });
}

- (instancetype)prism_AutoDot_initWithTarget:(id)target action:(SEL)action {
    //原始逻辑
    UIScreenEdgePanGestureRecognizer *gesture = [self prism_AutoDot_initWithTarget:target action:action];
    
    [gesture addTarget:self action:@selector(prism_AutoDot_edgePanAction:)];
    
    return gesture;
}

- (void)prism_AutoDot_addTarget:(id)target action:(SEL)action {
    //原始逻辑
    [self prism_AutoDot_addTarget:target action:action];
    
    [self prism_AutoDot_addTarget:self action:@selector(prism_AutoDot_edgePanAction:)];
}

- (void)prism_AutoDot_removeTarget:(id)target action:(SEL)action {
    //原始逻辑
    [self prism_AutoDot_removeTarget:target action:action];
    
    [self prism_AutoDot_removeTarget:self action:@selector(prism_AutoDot_edgePanAction:)];
}


#pragma mark - actions
- (void)prism_AutoDot_edgePanAction:(UIScreenEdgePanGestureRecognizer*)edgePanGestureRecognizer {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"target"] = self;
    params[@"action"] = NSStringFromSelector(@selector(prism_AutoDot_edgePanAction:));
    [[PrismEventDispatcher sharedInstance] dispatchEvent:PrismDispatchEventUIScreenEdgePanGestureRecognizerAction withSender:self params:[params copy]];
}

#pragma mark - private method

#pragma mark - property
- (NSNumber*)autoDotViewControllerCount {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setAutoDotViewControllerCount:(NSNumber*)autoDotViewControllerCount {
    objc_setAssociatedObject(self, @selector(autoDotViewControllerCount), autoDotViewControllerCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationController*)autoDotNavigationController {
    UINavigationController* (^block)(void) = objc_getAssociatedObject(self, @selector(autoDotNavigationController));
    return (block ? block() : nil);
}
- (void)setAutoDotNavigationController:(UINavigationController*)autoDotNavigationController {
    __weak UINavigationController *weakController = autoDotNavigationController;
    UINavigationController* (^block)(void) = ^{ return weakController; };
    objc_setAssociatedObject(self, @selector(autoDotNavigationController), block, OBJC_ASSOCIATION_COPY);
}
@end
