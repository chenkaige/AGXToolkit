//
//  UIViewController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIViewController+AGXCore.h"
#import "AGXBundle.h"
#import "NSObject+AGXCore.h"

NSTimeInterval AGXStatusBarStyleSettingDuration = 0.2;

@category_implementation(UIViewController, AGXCore)

- (UIStatusBarStyle)statusBarStyle {
    return [AGXBundle viewControllerBasedStatusBarAppearance] ?
    [self p_statusBarStyle] : [UIApplication sharedApplication].statusBarStyle;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self setStatusBarStyle:statusBarStyle animated:NO];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    if ([AGXBundle viewControllerBasedStatusBarAppearance]) {
        [self setP_statusBarStyle:statusBarStyle];
        if (animated) [UIView animateWithDuration:AGXStatusBarStyleSettingDuration
                                       animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
        else agx_async_main([self setNeedsStatusBarAppearanceUpdate];)
    } else {
        AGX_CLANG_Diagnostic(-Wdeprecated-declarations,
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];)
    }
}

NSString *const p_statusBarStyleKey = @"p_statusBarStyle";

- (UIStatusBarStyle)p_statusBarStyle {
    return [[self retainPropertyForAssociateKey:p_statusBarStyleKey] integerValue];
}

- (void)setP_statusBarStyle:(UIStatusBarStyle)p_statusBarStyle {
    [self setKVORetainProperty:@(p_statusBarStyle) forAssociateKey:p_statusBarStyleKey];
}

- (UIStatusBarStyle)AGXCore_preferredStatusBarStyle {
    return [self p_statusBarStyle];
}

- (void)AGXCore_UIViewController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:p_statusBarStyleKey];
    [self AGXCore_UIViewController_dealloc];
}

- (AGX_INSTANCETYPE)AGXCore_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIViewController *instance = [self AGXCore_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    instance.automaticallyAdjustsScrollViewInsets = NO; // change Defaults to NO
    return instance;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(preferredStatusBarStyle)
                         withNewSelector:@selector(AGXCore_preferredStatusBarStyle)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXCore_UIViewController_dealloc)];
        [self swizzleInstanceOriSelector:@selector(initWithNibName:bundle:)
                         withNewSelector:@selector(AGXCore_initWithNibName:bundle:)];
    });
}

- (UINavigationBar *)navigationBar {
    return self.navigationController.navigationBar;
}

- (BOOL)isNavigationBarHidden {
    return self.navigationController ? self.navigationController.navigationBarHidden : YES;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    self.navigationController.navigationBarHidden = navigationBarHidden;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
}

@end

@category_interface(UINavigationController, AGXCoreStatusBarStyle)
@end
@category_implementation(UINavigationController, AGXCoreStatusBarStyle)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self p_statusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return [self retainPropertyForAssociateKey:p_statusBarStyleKey] ? nil : self.topViewController;
}

@end
