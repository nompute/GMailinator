//
//  SearchManager.m
//  GMailinator
//
//  Created by Hajo Nils Krabbenhöft on 30.05.09.
//  Copyright 2009 Hajo Nils Krabbenhöft. All rights reserved.
//  Modifications by Michael Lai, 2013
//

#import "SearchManager.h"

@implementation SearchManager


- (IBAction)moveToFolder: sender {
	NSMenu* menu = [submenuMove submenu];
    [[self popupWithSubmenu: menu ] showWithSender:sender andTitle:@"Move to folder..."];
}

- (IBAction)moveToLastFolder: sender {
	NSMenu* menu = [submenuMove submenu];
	[self invokeLastFolder: menu];
}

- (IBAction)copyToFolder: sender {
	NSMenu* menu = [submenuCopy submenu];
    [[self popupWithSubmenu: menu ] showWithSender:sender andTitle:@"Copy to folder..."];
}

- (IBAction)copyToLastFolder: sender {
	NSMenu* menu = [submenuCopy submenu];
	[self invokeLastFolder: menu];
}

- (void)invokeLastFolder:(NSMenu*) submenu {
	if( [submenu numberOfItems] == 0 ) [[submenu delegate] menuNeedsUpdate: submenu ];
	[submenu update];
	
	NSArray     *items = [submenu itemArray];
    for(int iI = 0; iI < [items count]; iI++){
        NSMenuItem*  menuItem = [items objectAtIndex:iI];
		if(! [menuItem isEnabled] ) continue;
		
		NSString* title = [menuItem title];
		if( [title isEqualToString: lastFolder] ) {
			[submenu performActionForItemAtIndex: iI ];
			return;
		}
    }   
}

- (id)popupWithSubmenu:(NSMenu *)submenu
{
    if (!sp) {
        SearchPopup* popup = [[SearchPopup alloc] init];
        sp = popup;
    }
    
    [sp setSubmenu: submenu];

    // The call bellow, should be replace by:
    //
    //    [[NSBundle mainBundle] loadNibNamed:@"SearchPopup" owner:sp topLevelObjects:nil];
    //
    // But for reasons I still don't know, the proper way to load the xib makes the popup to not show!
    [NSBundle loadNibNamed: @"SearchPopup" owner:sp];

    return sp;
}

- (NSMenuItem *) newMenuItemWithTitle:(NSString *)title action:(SEL)action andKeyEquivalent:(NSString *)keyEquivalent inMenu:(NSMenu *)menu withTitle:(NSString*)searchTitle offset:(int)offset
// Taken from /System/Developer/Examples/EnterpriseObjects/AppKit/ModelerBundle/EOUtil.m
{
	// Simple utility category which adds a new menu item with title, action
	// and keyEquivalent to menu (or one of its submenus) under that item with
	// selector as its action.  Returns the new addition or nil if no such 
	// item could be found.
	
    NSMenuItem  *menuItem;
    NSArray     *items = [menu itemArray];
    int         iI;
	
    if(!keyEquivalent) {
        keyEquivalent = @"";
    }
	
    for (iI = 0; iI < [items count]; iI++) {
        menuItem = [items objectAtIndex:iI];

        if ([[menuItem title] isEqualToString:searchTitle]) {
            return ([menu insertItemWithTitle:title action:action keyEquivalent:keyEquivalent atIndex:iI + offset]);
        }
        else if([[menuItem target] isKindOfClass:[NSMenu class]]) {
            menuItem = [self newMenuItemWithTitle:title action:action andKeyEquivalent:keyEquivalent inMenu:[menuItem target] withTitle:searchTitle offset:offset];
            if (menuItem) return menuItem;
        }
    }

    return nil;
}

- (void) setContextMenu:(NSMenu *)menu {
    
    // create "Move to Folder..." menu item just below the existing "Move Again" menuitem
    NSMenuItem* moveFolderItem =  [self newMenuItemWithTitle: @"Move to Folder..."
                                                      action: @selector(moveToFolder:)
                                            andKeyEquivalent: @"l"
                                                      inMenu: [[NSApplication sharedApplication] mainMenu]
                                                   withTitle: @"Move Again"
                                                      offset: 1];
    [moveFolderItem setTarget: self];
    [moveFolderItem setKeyEquivalentModifierMask: 0];

    // lookup existing "Move to" and "Copy to" menuitems
    NSMenu* messagesMenu = [moveFolderItem menu];
    NSArray     *items = [messagesMenu itemArray];
    for (int iI = 0; iI < [items count]; iI++) {
        NSMenuItem*  menuItem = [items objectAtIndex:iI];
		
        if ([menuItem hasSubmenu]) {
			if([menuItem tag] == 105) submenuMove = menuItem;
            if([menuItem tag] == 106) submenuCopy = menuItem;
        }
    }   
}

- (void) setLastFolder: (NSString*) folder {
	lastFolder = folder;
	[menuitemLastMove setHidden:FALSE];
	[menuitemLastMove setTitle: [NSString stringWithFormat:@"Move selected messages to \"%@\"", folder]];
	[menuitemLastCopy setHidden:FALSE];
	[menuitemLastCopy setTitle: [NSString stringWithFormat:@"Copy selected messages to \"%@\"", folder]];
}

- (NSString*) lastFolder {
	return lastFolder;
}

- (NSMenuItem*) dbgSubmenuMove {
	return submenuMove;
}
- (NSMenuItem*) dbgSubmenuCopy{
	return submenuCopy;
}


@end
