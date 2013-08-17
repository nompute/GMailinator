//
//  SearchManager.h
//  Nostalgy4MailApp
//
//  Created by Hajo Nils Krabbenhöft on 30.05.09.
//  Copyright 2009 Hajo Nils KrabbenhöftHajo Nils Krabbenhöft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchPopup.h"

@interface SearchManager : NSObject {
#if 0
	IBOutlet NSMenu* contextMenu;
#endif
	NSMenuItem* submenuMove;
	NSMenuItem* submenuCopy;
	NSString* lastFolder;
    SearchPopup* sp;
	
	IBOutlet NSMenuItem* menuitemLastMove;
	IBOutlet NSMenuItem* menuitemLastCopy;
}

- (void) setContextMenu:(NSMenu *)menu;

- (IBAction)moveToFolder: sender;
- (IBAction)copyToFolder: sender;
- (IBAction)moveToLastFolder: sender;
- (IBAction)copyToLastFolder: sender;

- (void)invokeLastFolder:(NSMenu*) submenu;
- (void) setLastFolder: (NSString*) folder;
- (NSString*) lastFolder;

- (NSMenuItem*) dbgSubmenuMove;
- (NSMenuItem*) dbgSubmenuCopy;

@end
