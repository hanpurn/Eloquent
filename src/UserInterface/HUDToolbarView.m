//
//  HUDToolbarView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "HUDToolbarView.h"


@implementation HUDToolbarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    //[super drawRect:dirtyRect];
    
    NSRect rect = [self bounds];
    NSRect newRect = NSMakeRect(rect.origin.x+2, rect.origin.y+2, rect.size.width-3, rect.size.height-3);
    
    NSBezierPath *viewSurround = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:10 yRadius:10];
    [viewSurround setLineWidth:2.0];
    [[NSColor lightGrayColor] set];
    [viewSurround stroke];
    [[NSColor colorWithCalibratedWhite:0.25 alpha:0.95] set];
    [viewSurround fill];
}

@end
