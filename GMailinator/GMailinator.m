#import "GMailinator.h"
#import <objc/objc-runtime.h>
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>

NSBundle *GetGMailinatorBundle(void)
{
    return [NSBundle bundleForClass:[GMailinator class]];
}

@implementation GMailinator

+ (void)initialize {
    [GMailinator registerBundle];
    SearchManager* sm = [[SearchManager alloc] init];
    [sm setContextMenu: nil];
    objc_setAssociatedObject(GetGMailinatorBundle(),
                             @"searchManager",
                             sm,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)logAllSelectorsFromClass:(Class)cls {
    unsigned int methodCount = 0;
    Method * methodlist = class_copyMethodList(cls, &methodCount);

    NSLog(@"Class '%s' has %d methods", class_getName(cls), methodCount);
    for(int i = 0; i < methodCount; ++i) {
        NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(methodlist[i])));
    }
}

/**
 * Helper method to setup a class from Mail to use our custom methods instead of they common
 * keyDown:.
 */
+ (void)setupClass:(Class)cls swappingKeyDownWith:(SEL)overrideSelector {
    if (DEBUG) {
        [self logAllSelectorsFromClass:cls];
    }

    if (cls == nil) return;

    // Helper methods
    SEL performSelector = @selector(performSelectorOnMessageViewer:basedOnEvent:);
    SEL getShortcutSelector = @selector(getShortcutRemappedEventFor:);
    Method performMethod = class_getInstanceMethod(self, performSelector);
    Method getShortcutMethod = class_getInstanceMethod(self, getShortcutSelector);

    // Swapped methods
    SEL originalSelector = @selector(keyDown:);
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method overrideMethod = class_getInstanceMethod(self, overrideSelector);

    // Swap keyDow with the given method
    class_addMethod(cls,
                    overrideSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
    class_replaceMethod(cls,
                        originalSelector,
                        method_getImplementation(overrideMethod),
                        method_getTypeEncoding(overrideMethod));
    // Add helper methods
    class_addMethod(cls,
                    performSelector,
                    method_getImplementation(performMethod),
                    method_getTypeEncoding(performMethod));
    class_addMethod(cls,
                    getShortcutSelector,
                    method_getImplementation(getShortcutMethod),
                    method_getTypeEncoding(getShortcutMethod));
}

+ (void)load {
    [self setupClass:NSClassFromString(@"MailTableView")
 swappingKeyDownWith:@selector(overrideMailKeyDown:)];

    // this class does not exist on newer versions of Mail
//    [self setupClass:NSClassFromString(@"MessagesTableView")
// swappingKeyDownWith:@selector(overrideMessagesKeyDown:)];

    [self setupClass:NSClassFromString(@"MessageViewer")
 swappingKeyDownWith:@selector(overrideMessagesKeyDown:)];
}

+ (void)registerBundle {
    Class mailBundleClass = NSClassFromString(@"MVMailBundle");
    if(class_getClassMethod(mailBundleClass, @selector(registerBundle)))
        [mailBundleClass performSelector:@selector(registerBundle)];
}

/**
 * This method is where we perform known selectors on the message viewer. This is prefferable
 * over the shortcut proxy since a user could change their shortcuts, unfortunately there is no
 * documentation on which selectors the MessageViewer on Mail we could use.
 */
- (BOOL)performSelectorOnMessageViewer:(id)messageViewer basedOnEvent:(NSEvent*)event {
    unichar key = [[event characters] characterAtIndex:0];
    BOOL performed = YES;

    switch (key) {
        case '#': {
            [messageViewer performSelector:@selector(deleteMessages:) withObject:nil];
            break;
        }
        case 'a': {
            [messageViewer performSelector:@selector(replyAllMessage:) withObject:nil];
            break;
        }
        case 'c': {
            [messageViewer performSelector:@selector(showComposeWindow:) withObject:nil];
            break;
        }
        case 'e':
        case 'y': {
            [messageViewer performSelector:@selector(archiveMessages:) withObject:nil];
            break;
        }
        case 'f': {
            [messageViewer performSelector:@selector(forwardMessage:) withObject:nil];
            break;
        }
        case 'o': {
            [messageViewer performSelector:@selector(openMessages:) withObject:nil];
            break;
        }
        case 'R': {
            [messageViewer performSelector:@selector(checkNewMail:) withObject:nil];
            break;
        }
        case 'r': {
            [messageViewer performSelector:@selector(replyMessage:) withObject:nil];
            break;
        }
        case 's': {
            [messageViewer performSelector:@selector(toggleFlaggedStatus:) withObject:nil];
            break;
        }
        case 'u': {
            [messageViewer performSelector:@selector(markAsRead:) withObject:nil];
            break;
        }
        case 'U': {
            [messageViewer performSelector:@selector(markAsUnread:) withObject:nil];
            break;
        }
        default:
            performed = NO;
    }
    return performed;
}

/**
 * This method is a proxy for shortcuts. We receive the Gmail key presses and translate it to normal
 * Mail shortcuts. Althoug this is the easiest way to remap shortcuts it shouldn't be the primary
 * way since a user could remap the entire set of shortcuts and have weird behavior using this
 * plugin. Also there is the fact that some modifiers cannot be remapped, for instanse Alt+Up/Down
 * can be used to go to next and previous message on a thread, but when we remap them here, the
 * generated shortcut is the same as going to the beginning or end of the message list.
 */
-(NSEvent*)getShortcutRemappedEventFor:(NSEvent*)event {
    unichar key = [[event characters] characterAtIndex:0];
    NSEvent *newEvent = event;
    CGEventRef cgEvent = NULL;

    switch (key) {
        case '!': { // mark message as Spam
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_J, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskShift);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case '/': { // go to search field
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_F, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskAlternate);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'g': { // go to the beginning of the list
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_UpArrow, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskAlternate | kCGEventFlagMaskControl);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'G': { // go to the end of the list
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_DownArrow, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskAlternate | kCGEventFlagMaskControl);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'j': { // next message (down)
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_DownArrow, true);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'J': { // expand selection to next message (down)
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_DownArrow, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskShift);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'k': { // previous message (up)
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_UpArrow, true);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'K': { // expand selection to previous message (up)
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_UpArrow, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskShift);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'v': { // view raw message
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_U, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskAlternate);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
        case 'z': { // undo
            cgEvent = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_Z, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand);
            newEvent = [NSEvent eventWithCGEvent: cgEvent];
            break;
        }
    }

    if (cgEvent != NULL) {
        // prevent memory leak from the temporary CGEvent
        CFRelease(cgEvent);
    }

    return newEvent;
}

- (void)overrideMailKeyDown:(NSEvent*)event {
    id tableViewManager = [self performSelector:@selector(delegate)];
    id messageListViewController = [tableViewManager performSelector:@selector(delegate)];
    
    // NOTE: backwards compatibility. In 10.11 and earlier, tableViewManager.delegate.delegate was already the message viewer.
    id messageViewer
        = [messageListViewController respondsToSelector:@selector(messageViewer)]
        ? [messageListViewController performSelector:@selector(messageViewer)]
        : messageListViewController;

    if (! [self performSelectorOnMessageViewer:messageViewer basedOnEvent:event]) {
        [self overrideMailKeyDown:[self getShortcutRemappedEventFor:event]];
    }
}

- (void)overrideMessagesKeyDown:(NSEvent*)event {
    if (! [self performSelectorOnMessageViewer:self basedOnEvent:event]) {
        [self overrideMessagesKeyDown:[self getShortcutRemappedEventFor:event]];
    }
}

@end
