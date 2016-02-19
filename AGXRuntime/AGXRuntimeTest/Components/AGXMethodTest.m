//
//  AGXMethodTest.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXRuntime.h"

@interface MethodTestBean : NSObject
+ (NSString *)classMethod1;
+ (NSString *)classMethod2;
- (NSString *)instanceMethod1:(NSString *)param;
- (NSString *)instanceMethod2:(NSString *)param;
@end
@implementation MethodTestBean
+ (NSString *)classMethod1 { return @"classMethod1"; }
+ (NSString *)classMethod2 { return @"classMethod2"; }
- (NSString *)instanceMethod1:(NSString *)param { return @"instanceMethod1"; }
- (NSString *)instanceMethod2:(NSString *)param { return @"instanceMethod2"; }
@end

@interface AGXMethodTest : XCTestCase

@end

@implementation AGXMethodTest

- (void)testAGXMethod {
    AGXMethod *method1 = [AGXMethod classMethodWithName:@"classMethod1" inClassNamed:@"MethodTestBean"];
    AGXMethod *method2 = [AGXMethod classMethodWithName:@"classMethod2" inClassNamed:@"MethodTestBean"];
    XCTAssertEqualObjects([method1 selectorName], @"classMethod1");
    XCTAssertEqualObjects([method2 selectorName], @"classMethod2");
    IMP imp1 = [method1 implementation];
    IMP imp2 = [method2 implementation];
    [method1 setImplementation:imp2];
    [method2 setImplementation:imp1];
    XCTAssertEqualObjects([MethodTestBean classMethod1], @"classMethod2");
    XCTAssertEqualObjects([MethodTestBean classMethod2], @"classMethod1");
    
    
    method1 = [AGXMethod instanceMethodWithName:@"instanceMethod1:" inClassNamed:@"MethodTestBean"];
    method2 = [AGXMethod instanceMethodWithName:@"instanceMethod2:" inClassNamed:@"MethodTestBean"];
    XCTAssertEqualObjects([method1 selectorName], @"instanceMethod1:");
    XCTAssertEqualObjects([method2 selectorName], @"instanceMethod2:");
    imp1 = [method1 implementation];
    imp2 = [method2 implementation];
    [method1 setImplementation:imp2];
    [method2 setImplementation:imp1];
    XCTAssertEqualObjects([[[MethodTestBean alloc] init] instanceMethod1:nil], @"instanceMethod2");
    XCTAssertEqualObjects([[[MethodTestBean alloc] init] instanceMethod2:nil], @"instanceMethod1");
}

@end
