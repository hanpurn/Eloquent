//
//  HostWindow.m
//  Eloquent
//
//  Created by Manfred Bergmann on 05.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HostWindow.h"


@implementation HostWindow

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setTitleVisibility:NSWindowTitleHidden];
    
    NSVisualEffectView *effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, 300, 180)];
    [effectView setMaterial:NSVisualEffectMaterialDark];
    [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [effectView setState:NSVisualEffectStateActive];
    
//    [self setStyleMask:[self styleMask] | NSFullSizeContentViewWindowMask];
//    [self setTitlebarAppearsTransparent:NO];
    
//    [[self contentView] addSubview:effectView];
    
    /*
    [[self contentView] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[effectView]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"effectView": effectView}]];
    [[self contentView] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[effectView]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"effectView": effectView}]];
     */
}

- (IBAction)leftSideBarHideShow:(id)sender {
    [[self delegate] performSelector:@selector(leftSideBarHideShow:) withObject:sender];
}

- (IBAction)rightSideBarHideShow:(id)sender {
    [[self delegate] performSelector:@selector(rightSideBarHideShow:) withObject:sender];
}

- (IBAction)switchLookupView:(id)sender {
    [[self delegate] performSelector:@selector(switchLookupView:) withObject:sender];
}

- (IBAction)navigationAction:(id)sender {
    [[self delegate] performSelector:@selector(navigationAction:) withObject:sender];
}

- (IBAction)navigationBack:(id)sender {
    [[self delegate] performSelector:@selector(navigationBack:) withObject:sender];
}

- (IBAction)navigationForward:(id)sender {
    [[self delegate] performSelector:@selector(navigationForward:) withObject:sender];
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [[self delegate] performSelector:@selector(fullScreenModeOnOff:) withObject:sender];
}

- (IBAction)focusSearchEntry:(id)sender {
    [[self delegate] performSelector:@selector(focusSearchEntry:) withObject:sender];
}

- (IBAction)nextBook:(id)sender {
    [[self delegate] performSelector:@selector(nextBook:) withObject:sender];
}

- (IBAction)previousBook:(id)sender {
    [[self delegate] performSelector:@selector(previousBook:) withObject:sender];
}

- (IBAction)nextChapter:(id)sender {
    [[self delegate] performSelector:@selector(nextChapter:) withObject:sender];
}

- (IBAction)previousChapter:(id)sender {
    [[self delegate] performSelector:@selector(previousChapter:) withObject:sender];
}

- (IBAction)performClose:(id)sender {
    [[self delegate] performSelector:@selector(performClose:) withObject:sender];
}



@end
