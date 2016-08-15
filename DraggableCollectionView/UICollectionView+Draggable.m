//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "UICollectionView+Draggable.h"
#import "LSCollectionViewHelper.h"
#import <objc/runtime.h>

@implementation UICollectionView (Draggable)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(didMoveToWindow);
        SEL swizzledSelector = @selector(didMoveToWindowWithHelpers);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }

    });
}

- (BOOL) helperAllocated {
    return objc_getAssociatedObject(self, "LSCollectionViewHelper") != nil;
}

- (LSCollectionViewHelper *)getHelper {
    LSCollectionViewHelper *helper = objc_getAssociatedObject(self, "LSCollectionViewHelper");
    if (helper == nil) {
        helper = [[LSCollectionViewHelper alloc] initWithCollectionView:self];
        objc_setAssociatedObject(self, "LSCollectionViewHelper", helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

- (void) removeHelper {
    LSCollectionViewHelper *helper = objc_getAssociatedObject(self, "LSCollectionViewHelper");
    if (helper != nil) {
        objc_removeAssociatedObjects(helper);
    }
}

- (BOOL)draggable {
    return [self getHelper].enabled;
}

- (void)setDraggable:(BOOL)draggable {
    [self getHelper].enabled = draggable;
}

- (UIEdgeInsets)scrollingEdgeInsets {
    return [self getHelper].scrollingEdgeInsets;
}

- (void)setScrollingEdgeInsets:(UIEdgeInsets)scrollingEdgeInsets {
    [self getHelper].scrollingEdgeInsets = scrollingEdgeInsets;
}

- (CGFloat)scrollingSpeed {
    return [self getHelper].scrollingSpeed;
}

- (void)setScrollingSpeed:(CGFloat)scrollingSpeed {
    [self getHelper].scrollingSpeed = scrollingSpeed;
}

- (void) didMoveToWindowWithHelpers {
    [self didMoveToWindowWithHelpers];
    if ([self helperAllocated]) {
        if (self.window) {
            [[self getHelper] collectionViewWillAppear];
        } else {
            [[self getHelper] collectionViewWillDisappear];
        }
    }
}

@end
