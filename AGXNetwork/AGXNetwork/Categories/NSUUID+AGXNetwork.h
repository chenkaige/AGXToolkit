//
//  NSUUID+AGXNetwork.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_NSUUID_AGXNetwork_h
#define AGXNetwork_NSUUID_AGXNetwork_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXCategory.h>

@category_interface(NSUUID, AGXNetwork)
+ (AGX_INSTANCETYPE)UUIDWithUUIDString:(NSString *)string;
+ (AGX_INSTANCETYPE)UUIDWithUUIDBytes:(const uuid_t)bytes;
@end

#endif /* AGXNetwork_NSUUID_AGXNetwork_h */