/*
 *  SubviewHosting.h
 *  MacSword2
 *
 *  Created by Manfred Bergmann on 21.06.08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <SwordModule.h>
#import <Indexer.h>

@class HostableViewController;

@protocol SubviewHosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;
@end

@protocol MouseTracking
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;
@end

@protocol FullScreenCapability
- (BOOL)isFullScreenMode;
- (void)setFullScreenMode:(BOOL)flag;
- (IBAction)fullScreenModeOnOff:(id)sender;
@end

@protocol AccessoryViewProviding
- (NSView *)topAccessoryView;
- (NSView *)rightAccessoryView;
- (void)adaptTopAccessoryViewComponentsForSearchType:(SearchType)aType;
- (BOOL)showsRightSideBar;
@end

@protocol TextContentProviding
- (NSTextView *)textView;
- (NSScrollView *)scrollView;
- (void)setAttributedString:(NSAttributedString *)aString;
- (void)setString:(NSString *)aString;
- (void)textChanged:(NSNotification *)aNotification;
@end

@protocol ContentSaving
- (BOOL)hasUnsavedContent;
- (void)saveContent;
@end

@protocol TextDisplayable
- (void)displayText;
- (void)displayTextForReference:(NSString *)aReference;
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;
@end

@protocol TextDisplayableExt
- (BOOL)hasValidCacheObject;
- (void)handleDisplayForReference;
- (void)handleDisplayIndexedNoHasIndex;
- (void)handleDisplayIndexedPerformSearch;
- (void)handleDisplayCached;
- (void)handleDisplayStatusText;
@end

@protocol ModuleProviding
- (SwordModule *)module;
@end

@protocol ProgressIndicating
- (void)beginIndicateProgress;
- (void)endIndicateProgress;
@end

@protocol ContextMenuProviding
- (NSMenu *)textContextMenu;
- (NSMenu *)linkContextMenu;
- (NSMenu *)imageContextMenu;
@end
