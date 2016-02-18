//
//  SwordSearching.m
//  Eloquent
//
// Copyright 2008 Manfred Bergmann
// Based on code by Will Thimbleby
//

#import <ObjCSword/ObjCSword.h>
#import "CocoLogger/CocoLogger.h"
#import "IndexingManager.h"
#import "SearchResultEntry.h"
#import "SwordModule+SearchKitIndex.h"
#import "Indexer.h"

NSString *EloquentIndexVersion = @"1.2";

@interface SwordBible(SearchKitIndex)
- (void)indexContentsIntoIndex:(Indexer *)indexer;
@end

@interface SwordCommentary(SearchKitIndex)
- (void)indexContentsIntoIndex:(Indexer *)indexer;
@end

@interface SwordDictionary(SearchKitIndex)
- (void)indexContentsIntoIndex:(Indexer *)indexer;
@end

@interface SwordBook(SearchKitIndex)
- (void)indexContentsIntoIndex:(Indexer *)indexer;
- (void)indexContents:(NSString *)treeKey intoIndex:(Indexer *)indexer;
@end


@implementation SwordModule(SearchKitIndex)

/**
 generates a path index for the given VerseKey
 */
- (NSString *)indexOfVerseKey:(SwordVerseKey *)vk {
    NSString *index = [NSString stringWithFormat:@"%003i/%003i/%003i/%003i/%@", 
                       [vk testament],
                       [vk book],
                       [vk chapter],
                       [vk verse],
                       [vk osisBookName]];
    
    return index;
}

- (BOOL)hasSKSearchIndex {
    IndexingManager *im	= [IndexingManager sharedManager]; 
	NSString *modName = [self name];
    NSString *path = [im indexFolderPathForModuleName:modName];
    BOOL ret = NO;
    
    if([im indexExistsForModuleName:[self name]]) {
        NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"version.plist"]];
        if(d) {		
            if([d[@"Eloquent Index Version"] isEqualToString:EloquentIndexVersion]) {
                if((d[@"Sword Module Version"] == NULL) ||
                    ([d[@"Sword Module Version"] isEqualToString:[self version]])) {
                    CocoLog(LEVEL_INFO, @"module %@ has valid index", modName);
                    ret = YES;
                } 
				else {
                    //index out of date remove it
                    CocoLog(LEVEL_INFO, @"module %@ has no valid index!", modName);
                    [im removeIndexForModuleName:modName];
                }
            } 
			else {
                //index out of date remove it
                CocoLog(LEVEL_INFO, @"module %@ has no valid index!", modName);
				[im removeIndexForModuleName:modName];
            }
        }
		else {
			CocoLog(LEVEL_DEBUG, @"version.plist for module %@ was not found.", modName);			
		}
    }
	else {
		CocoLog(LEVEL_DEBUG, @"index for module %@ was not found.", modName);
	}
    
	return ret;
}

/**
 \brief This message is used to force an index rebuild.
 */
- (void)recreateSKSearchIndex {
	[self deleteSKSearchIndex];
}

- (void)deleteSKSearchIndex {
    [self.indexLock lock];
	if([self hasSKSearchIndex]) {
		[[IndexingManager sharedManager] removeIndexForModuleName:[self name]];
	}    
    [self.indexLock unlock];
}

- (void)createSKSearchIndex {
    [self createSKSearchIndexWithProgressIndicator:nil];
}

- (void)createSKSearchIndexWithProgressIndicator:(id<IndexCreationProgressing>)progressIndicator {
    [self.indexLock lock];
    
	// get Indexer
    Indexer *indexer = [[IndexingManager sharedManager] indexerForModuleName:[self name] 
                                                                  moduleType:[SwordModule moduleTypeForModuleTypeString:[self typeString]]];
    if(indexer == nil) {
        CocoLog(LEVEL_ERR, @"Could not create Indexer for this module!");
    } else {
        CocoLog(LEVEL_DEBUG, @"start indexing...");
        
        // add one step for the flush operation
        if(progressIndicator) {
            [progressIndicator addToMaxProgressValue:10.0];
        }
        
        [indexer setProgressIndicator:progressIndicator];
        [self indexContentsIntoIndex:indexer];
        [indexer flushIndex];
        [[IndexingManager sharedManager] closeIndexer:indexer];
        
        if(progressIndicator) {
            [progressIndicator incrementProgressBy:10.0];
        }
        
        CocoLog(LEVEL_DEBUG, @"stopped indexing");
        
        //save version info
        NSString *path = [[IndexingManager sharedManager] indexFolderPathForModuleName:[self name]];
        NSDictionary *d = @{@"Eloquent Index Version" : EloquentIndexVersion,
                            @"Sword Module Version" : [self version]};
        [d writeToFile:[path stringByAppendingPathComponent:@"version.plist"] atomically:NO];
    }
    
    if(delegate) {
        if([delegate respondsToSelector:@selector(indexCreationFinished:)]) {
            [delegate performSelectorOnMainThread:@selector(indexCreationFinished:) withObject:self waitUntilDone:YES];
        }
        delegate = nil;
    }
    [self.indexLock unlock];
}

- (void)createSKSearchIndexThreadedWithDelegate:(id)aDelegate progressIndicator:(id<IndexCreationProgressing>)progressIndicator {
    delegate = aDelegate;
    [NSThread detachNewThreadSelector:@selector(createSKSearchIndexWithProgressIndicator:) toTarget:self withObject:progressIndicator];
}

/** abstract method */
- (void)indexContentsIntoIndex:(Indexer *)indexer {
}

- (NSArray *)performSKIndexSearch:(NSString *)searchString {
    return [NSArray array];
}

- (NSArray *)performSKIndexSearch:(NSString *)searchString constrains:(id)constrains maxResults:(int)maxResults {
	// get Indexer
    Indexer *indexer = [[IndexingManager sharedManager] indexerForModuleName:[self name] 
                                                                  moduleType:[SwordModule moduleTypeForModuleTypeString:[self typeString]]];
    return [indexer performSearchOperation:searchString constrains:constrains maxResults:maxResults];
}

@end

@implementation SwordBible(SearchKitIndex)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    
    BOOL savePEA = [self processEntryAttributes];

    if([self hasFeature:SWMOD_FEATURE_STRONGS] || [self hasFeature:SWMOD_FEATURE_LEMMA]) {
        [self setProcessEntryAttributes:YES];
    }
	
    if([indexer progressIndicator] != nil) {
        [[indexer progressIndicator] addToMaxProgressValue:(double)[[self bookList] count]];
        [[indexer progressIndicator] setProgressIndeterminate:NO];
    }
    
    [self.moduleLock lock];
    for(SwordBibleBook *bb in [self bookList]) {
        
		@autoreleasepool {
        
            SwordListKey *lk = [SwordListKey listKeyWithRef:[bb osisName] v11n:[self versification]];    
            [lk setPersist:NO];
            [lk setPosition:SWPOS_TOP];
            NSString *ref;
            NSString *stripped;
            while(![lk error]) {
                ref = [lk keyText];
                [self setSwordKey:lk];
                stripped = [self strippedText];
                
                NSMutableDictionary *properties = [@{IndexPropSwordKeyString : ref} mutableCopy];
                NSString *keyIndex = [self indexOfVerseKey:[SwordVerseKey verseKeyWithRef:ref v11n:[self versification]]];
                
                NSMutableString *strongStr = [NSMutableString string];
                if([self processEntryAttributes]) {
                    NSArray *strongNumbers = [self entryAttributeValuesLemmaNormalized];
                    if(strongNumbers && [strongNumbers count] > 0) {
                        for(NSString *strongNumber in strongNumbers) {
                            [strongStr appendFormat:@"strong:%@ ", strongNumber];
                        }
                        // also add to dictionary
                        properties[IndexPropSwordStrongString] = strongStr;
                    }
                }
                
                if((stripped && [stripped length] > 0) || (strongStr && [strongStr length] > 0)) {
                    NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", stripped, strongStr];                
                    // add to index
                    [indexer addDocument:keyIndex text:indexContent textType:ContentTextType storeDict:properties];                
                }
                
                [lk increment];
            }
        
		}
        
        if([indexer progressIndicator] != nil) {
            [[indexer progressIndicator] incrementProgressBy:1.0];
        }
    }
    [self.moduleLock unlock];

	[self setProcessEntryAttributes:savePEA];
}

@end

@implementation SwordCommentary(SearchKitIndex)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    
    if([indexer progressIndicator] != nil) {
        [[indexer progressIndicator] addToMaxProgressValue:(double)[[self bookList] count]];
        [[indexer progressIndicator] setProgressIndeterminate:NO];
    }

    [self.moduleLock lock];
    for(SwordBibleBook *bb in [self bookList]) {
        
		@autoreleasepool {

        // we want to skip consecutive links. Commentary module does this by default.
            SwordListKey *lk = [SwordListKey listKeyWithRef:[bb osisName] v11n:[self versification]];    
            [lk setPersist:YES];
            [lk setPosition:SWPOS_TOP];
            [self setSwordKey:lk];
            NSString *ref;
            NSString *stripped;
            while(![self error]) {
                ref = [lk keyText];
                stripped = [self strippedText];
                
                NSDictionary *properties = @{IndexPropSwordKeyString : ref};
                NSString *keyIndex = [self indexOfVerseKey:[SwordVerseKey verseKeyWithRef:ref v11n:[self versification]]];
                if(stripped && [stripped length] > 0) {
                    [indexer addDocument:keyIndex text:stripped textType:ContentTextType storeDict:properties];                
                }
                
                [self incKeyPosition];
            }

		}

        if([indexer progressIndicator] != nil) {
            [[indexer progressIndicator] incrementProgressBy:1.0];
        }
    }
    // reset key
    [self setKeyString:@"gen"];

    [self.moduleLock unlock];
}

@end

@implementation SwordDictionary(SearchKitIndex)

- (void)indexContentsIntoIndex:(Indexer *)indexer {    

    if([indexer progressIndicator] != nil) {
        [[indexer progressIndicator] addToMaxProgressValue:(double)[[self allKeys] count]];
        [[indexer progressIndicator] setProgressIndeterminate:NO];
    }

    @autoreleasepool {
        for(NSString *key in [self allKeys]) {
            // entryForKey does lock
            NSString *entry = [self entryForKey:key];
            
            if(entry != nil) {
                NSDictionary *properties = @{IndexPropSwordKeyString : key};
                if([entry length] > 0) {
                    NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", key, entry];
                    [indexer addDocument:key text:indexContent textType:ContentTextType storeDict:properties];                
                }
            }

            if([indexer progressIndicator] != nil) {
                [[indexer progressIndicator] incrementProgressBy:1.0];
            }
        }
    }        
}

@end

@implementation SwordBook(SearchKitIndex)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    // we start at root
	[self indexContents:nil intoIndex:indexer];
}

- (void)indexContents:(NSString *)treeKey intoIndex:(Indexer *)indexer {
    
    SwordModuleTreeEntry *entry = [self treeEntryForKey:treeKey];

    if([indexer progressIndicator] != nil) {
        [[indexer progressIndicator] addToMaxProgressValue:(double)[[entry content] count]];
        [[indexer progressIndicator] setProgressIndeterminate:NO];
    }

    for(NSString *key in [entry content]) {
        NSArray *strippedArray = [self strippedTextEntriesForRef:key];
        if(strippedArray != nil) {
            // get content
            NSString *stripped = [(SwordModuleTextEntry *) strippedArray[0] text];
            // define properties
            NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:2];
            // additionally save content
            //[propDict setObject:stripped forKey:IndexPropSwordKeyContent];
            propDict[IndexPropSwordKeyString] = key;
            
            if([stripped length] > 0) {
                // let's add the key also into the searchable content
                NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", key, stripped];
                
                // add content with key
                [indexer addDocument:key text:indexContent textType:ContentTextType storeDict:propDict];                
            }
        }

        // go deeper
        [self indexContents:key intoIndex:indexer];
        
        if([indexer progressIndicator] != nil) {
            [[indexer progressIndicator] incrementProgressBy:1.0];
        }        
	}
}

@end
