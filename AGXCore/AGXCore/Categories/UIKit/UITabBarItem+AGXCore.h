//
//  UITabBarItem+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UITabBarItem_AGXCore_h
#define AGXCore_UITabBarItem_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UITabBarItem, AGXCore)
+ (AGX_INSTANCETYPE)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;

+ (UIOffset)titlePositionAdjustment;
+ (void)setTitlePositionAdjustment:(UIOffset)titlePositionAdjustment;
@end

#endif /* AGXCore_UITabBarItem_AGXCore_h */
