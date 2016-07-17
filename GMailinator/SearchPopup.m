//
//  SearchPopup.m
//  Nostalgy4MailApp
//
//  Created by Hajo Nils Krabbenhöft on 30.05.09.
//  Copyright 2009 Hajo Nils Krabbenhöft. All rights reserved.
//

#import "SearchPopup.h"
#import "Ranker.h"

@implementation SearchPopup

- (void)setSubmenu:(NSMenu*)sm {
    submenu = sm;
}

- (void)addMenu:(NSMenu *)menu toDictionary:(NSMutableDictionary *)dict withPath:(NSMutableArray *)path atLevel:(int)depth
{
    NSArray *items = [menu itemArray];
    for (int i = 0; i < [items count]; ++i)
    {
        NSMenuItem *menuItem = [items objectAtIndex:i];
        long level = depth + [menuItem indentationLevel];
        
        // Remove items below this item.
        for (long l = [path count] - 1; l > level; --l)
            [path removeObjectAtIndex:l];
        
        // Add this menu item to the path at the appropriate level.
        [path setObject:[menuItem title] atIndexedSubscript:level];
        NSString *key = [path componentsJoinedByString:@"/"];
        
        if ([menuItem isEnabled])
            [dict setObject:menuItem forKey:key];
        
        if ([menuItem hasSubmenu])
            [self addMenu:[menuItem submenu]
                toDictionary:dict
                 withPath:path
                  atLevel:(int)level + 1];
    }
}

- (id) init
{
    self = [super init];
        
    currentResults = [NSMutableArray array];
    //[currentResults retain]; // Is to nessecary?
    
    return self;
}

- (void)showWithSender: sender andTitle: (NSString *)title {

	// update menu items
	[[submenu delegate] menuNeedsUpdate: submenu ];
    
	// set message handling to copy / move
    if ([submenu respondsToSelector:@selector(_sendMenuOpeningNotification:)]) { // Yosemite 10.10.2
        [submenu performSelector:@selector(_sendMenuOpeningNotification:)];
    } else if ([submenu respondsToSelector:@selector(_sendMenuOpeningNotification)]) {
        [submenu performSelector:@selector(_sendMenuOpeningNotification)];
    }
	
//	if ([p lastFolder] != nil)
//    {
//		[searchField setStringValue: [p lastFolder]];
//		[self doSearch: sender];
//		[searchField selectText: sender];
//	}

    [searchWindow setTitle:title];
	[searchWindow makeKeyAndOrderFront: sender];
    [searchField becomeFirstResponder];
}

NSInteger compareMatch(id l_row, id r_row, void *query)
{
    double l_rank = calculate_rank(
        (NSString *)[(NSDictionary*)l_row objectForKey:@"path"],
        (__bridge NSString *)query);
    
    double r_rank = calculate_rank(
        (NSString *)[(NSDictionary*)r_row objectForKey:@"path"],
        (__bridge NSString *)query);
    
    if (l_rank == r_rank)
        return NSOrderedSame;    
    else
        return l_rank > r_rank
        ? NSOrderedAscending
        : NSOrderedDescending;
}

- (IBAction)doSearch: sender
{
	NSString *searchString = [searchField stringValue];

    // Clear all previous results.
    [currentResults removeAllObjects];
    
    // All the available folders will be collected in here.
    NSMutableDictionary *folders = [NSMutableDictionary dictionary];
    
    // And we will use this array as a sort of stack to keep track of the path
    // of each folder, which we use to generate the path string.
    NSMutableArray *path = [NSMutableArray array];
    
    [submenu update];
    [self addMenu:submenu toDictionary:folders withPath:path atLevel:0];
	
    // Filter the folders to only include folders that somehow match.
    for (NSString *path in folders)
    {
        if ([searchString length] == 0 || is_subset(searchString, path))
            [currentResults addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       path, @"path",
                                       [folders objectForKey:path], @"menuItem",
                                       nil]];
    }
    
    // Sort the folders according to how well they match with the search string.
    [currentResults sortUsingFunction:compareMatch context: (__bridge void *)(searchString)];

    selectedResult = [currentResults count] > 0
        ? [currentResults objectAtIndex:0]
        : nil;
	
	[resultViewer reloadData];
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    if (commandSelector == @selector(insertNewline:))
    {
		if (selectedResult != nil)
        {
//			[parent setLastFolder: selectedResult objectAtIndex:0]];
            NSMenuItem *menuItem = [selectedResult objectForKey:@"menuItem"];
            NSMenu *menu = [menuItem menu];
            NSInteger index = [menu indexOfItem:menuItem];
            [menu performActionForItemAtIndex:index];
		}
        
		[searchWindow orderOut:nil];
		result = YES;
    }
	else if (commandSelector == @selector(cancelOperation:))
    {
		[searchWindow orderOut:nil];
		result = YES;
	}
	else if (commandSelector == @selector(moveUp:))
    {
		 if (selectedResult != nil)
         {
			 long index = [currentResults indexOfObject:selectedResult] - 1;

			 if (index < 0)
                 index = 0;
			 
             selectedResult = [currentResults objectAtIndex:index];
			 [resultViewer selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:FALSE];
			 [resultViewer scrollRowToVisible:index];
		 }
		 result = YES;
	}
	else if (commandSelector == @selector(moveDown:))
    {
		 if (selectedResult != nil)
         {
			 long index = [currentResults indexOfObject: selectedResult] + 1;
             
			 if (index >= [currentResults count])
                 index = [currentResults count] - 1;
             
			 selectedResult = [currentResults objectAtIndex:index];
			 [resultViewer selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:FALSE];
			 [resultViewer scrollRowToVisible:index];
		 }
		 result = YES;
	}
    
    return result;
}

- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(int)rowIndex
{	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [currentResults count]);
    NSDictionary* row = [currentResults objectAtIndex:rowIndex];
    
	if ([[column identifier] isEqualToString: @"image"])
        return [[row objectForKey:@"menuItem"] image];
    
    if ([[column identifier] isEqualToString: @"title"])
        return [row objectForKey:@"path"];
    
    return 0;
}

- (long)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [currentResults count];
}

- (IBAction)changeSelection:sender
{
	long i = [resultViewer selectedRow];
    
	if (i >= 0 && i < [currentResults count])
		selectedResult = [currentResults objectAtIndex: i];
	else 
		selectedResult = nil;
}

@end
