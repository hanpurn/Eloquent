//
//  SwordKey.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#include <swkey.h>
#endif

@interface SwordKey : NSObject {
#ifdef __cplusplus
    sword::SWKey *sk;
#endif
    BOOL created;
}

+ (id)swordKey;
+ (id)swordKeyWithRef:(NSString *)aRef;

#ifdef __cplusplus
- (id)initWithSWKey:(sword::SWKey *)aSk;
- (sword::SWKey *)swKey;
#endif

- (id)initWithRef:(NSString *)aRef;

- (void)setPosition:(int)aPosition;
- (void)decrement;
- (void)increment;
- (NSString *)keyText;
- (void)setKeyText:(NSString *)aKey;

@end