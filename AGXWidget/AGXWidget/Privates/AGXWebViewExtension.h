//
//  AGXWebViewExtension.h
//  AGXWidget
//
//  Created by Char Aznable on 16/3/16.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewExtension_h
#define AGXWidget_AGXWebViewExtension_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXEvaluateJavascriptDelegate.h"

@protocol AGXWebViewExtensionDelegate;

@interface AGXWebViewExtension : NSObject
@property (nonatomic, AGX_WEAK) id<AGXWebViewExtensionDelegate> delegate;
@property (nonatomic, assign) BOOL autoCoordinateBackgroundColor; // default YES

- (void)coordinateBackgroundColor;
@end

@protocol AGXWebViewExtensionDelegate <AGXEvaluateJavascriptDelegate>
- (void)coordinateWithBackgroundColor:(UIColor *)backgroundColor;
@end

#endif /* AGXWidget_AGXWebViewExtension_h */
