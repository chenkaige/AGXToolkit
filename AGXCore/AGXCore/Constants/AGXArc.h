//
//  AGXArc.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXArc_h
#define AGXCore_AGXArc_h

#import "AGXObjC.h"

#define AGX_IS_ARC                      __has_feature(objc_arc)

#if AGX_IS_ARC
# define AGX_STRONG                     strong
# define __AGX_STRONG                   __strong
#else
# define AGX_STRONG                     retain
# define __AGX_STRONG
#endif

#if __has_feature(objc_arc_weak)
# define AGX_WEAK                       weak
# define __AGX_WEAK                     __weak
#elif AGX_IS_ARC
# define AGX_WEAK                       unsafe_unretained
# define __AGX_WEAK                     __unsafe_unretained
#else
# define AGX_WEAK                       assign
# define __AGX_WEAK
#endif

#if AGX_IS_ARC
# define __AGX_AUTORELEASE              __autoreleasing
#else
# define __AGX_AUTORELEASE
#endif

#if AGX_IS_ARC
# define AGX_JUST_AUTORELEASE(exp)
# define AGX_AUTORELEASE(exp)           exp
# define AGX_RELEASE(exp)
# define AGX_RETAIN(exp)                exp
# define AGX_SUPER_DEALLOC
#else
# define AGX_JUST_AUTORELEASE(exp)      [(exp) autorelease]
# define AGX_AUTORELEASE(exp)           [(exp) autorelease]
# define AGX_RELEASE(exp)               [(exp) release]
# define AGX_RETAIN(exp)                [(exp) retain]
# define AGX_SUPER_DEALLOC              [super dealloc]
#endif

#if AGX_IS_ARC
# define AGX_BRIDGE                     __bridge
# define AGX_BRIDGE_TRANSFER            __bridge_transfer
# define AGX_BRIDGE_RETAIN              __bridge_retained
# define AGX_CFRelease(exp)             CFRelease((exp))
#else
# define AGX_BRIDGE
# define AGX_BRIDGE_TRANSFER
# define AGX_BRIDGE_RETAIN
# define AGX_CFRelease(exp)
#endif

#if AGX_IS_ARC
# define __AGX_WEAK_RETAIN              __weak
# define AGX_BLOCK_COPY(exp)            exp
# define AGX_BLOCK_RELEASE(exp)
# define AGX_BLOCK_AUTORELEASE(exp)     exp
#else
# define __AGX_WEAK_RETAIN              __block
# define AGX_BLOCK_COPY(exp)            _Block_copy((exp))
# define AGX_BLOCK_RELEASE(exp)         _Block_release((exp))
# define AGX_BLOCK_AUTORELEASE(exp)     [[(exp) copy] autorelease]
#endif

#define AGX_DISPATCH                    AGX_STRONG

#if AGX_IS_ARC
# define agx_dispatch_retain(exp)       exp
# define agx_dispatch_release(exp)
#else
# define agx_dispatch_retain(exp)       dispatch_retain((exp))
# define agx_dispatch_release(exp)      dispatch_release((exp))
#endif

#if AGX_IS_ARC
# define AGX_PerformSelector(exp)       AGX_CLANG_Diagnostic(-Warc-performSelector-leaks, exp)
#else
# define AGX_PerformSelector(exp)       exp
#endif

#endif /* AGXCore_AGXArc_h */
