#import "GMailinator.h"
#import <objc/objc-runtime.h>
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
    objc_setAssociatedObject(GetGMailinatorBundle(), @"searchManager", sm, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    // Add shortcuts to the mailbox list
    Class c = NSClassFromString(@"MailTableView");
    SEL originalSelector = @selector(keyDown:);
    SEL overrideSelector = @selector(overrideMailKeyDown:);
    Method originalMethod = class_getInstanceMethod(c, originalSelector);
    Method overrideMethod = class_getInstanceMethod(self, overrideSelector);

    class_addMethod(c, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    class_replaceMethod(c, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod));

    // Add shortcuts to the messages list
    c = NSClassFromString(@"MessagesTableView");
    originalSelector = @selector(keyDown:);
    overrideSelector = @selector(overrideMessagesKeyDown:);
    originalMethod = class_getInstanceMethod(c, originalSelector);
    overrideMethod = class_getInstanceMethod(self, overrideSelector);

    class_addMethod(c, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    class_replaceMethod(c, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod));

    // Add shortcuts to the messages list
    c = NSClassFromString(@"MessageViewer");
    originalSelector = @selector(keyDown:);
    overrideSelector = @selector(overrideMessagesKeyDown:);
    originalMethod = class_getInstanceMethod(c, originalSelector);
    overrideMethod = class_getInstanceMethod(self, overrideSelector);

    class_addMethod(c, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    class_replaceMethod(c, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod));

    NSLog(@"OLD STLYE");
}

+ (void)registerBundle
{
    if(class_getClassMethod(NSClassFromString(@"MVMailBundle"), @selector(registerBundle)))
        [NSClassFromString(@"MVMailBundle") performSelector:@selector(registerBundle)];

    //[[self class] load];
}


- (void)overrideMailKeyDown:(NSEvent*)event {
    unichar key = [[event characters] characterAtIndex:0];

    switch (key) {
        case 'e':
        case 'y': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 12, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskControl);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
//        case 'h': {
//            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 115, true)];
//            [self overrideMailKeyDown: newEvent];
//            break;
//        }
//        case 'l': {
//            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 119, true)];
//            [self overrideMailKeyDown: newEvent];
//            break;
//        }
        case 'k': {
            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 126, true)];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case 'K': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 126, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskShift);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case 'j': {
            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 125, true)];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case 'J': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 125, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskShift);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case '#': {
            id messageViewer = [[self performSelector:@selector(delegate)] performSelector:@selector(delegate)];
            [messageViewer performSelector:@selector(deleteMessages:) withObject:nil];
            break;
        }
        case 'c': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 45, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case 'r': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 15, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case 'a': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 15, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskShift);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case 'f': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 3, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskShift);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        case '/': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 3, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskAlternate);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        default:
            [self overrideMailKeyDown:event];
            break;
            
    }
}

- (void)overrideMessagesKeyDown:(NSEvent*)event {
    unichar key = [[event characters] characterAtIndex:0];

    switch (key) {
        case 'e':
        case 'y': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 12, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskControl);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMessagesKeyDown: newEvent];
            break;
        }
//        case 'h': {
//            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 115, true)];
//            [self overrideMessagesKeyDown: newEvent];
//            break;
//        }
//        case 'l': {
//            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 119, true)];
//            [self overrideMessagesKeyDown: newEvent];
//            break;
//        }
        case 'k': {
            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 123, true)];
            [self overrideMessagesKeyDown: newEvent];
            break;
        }
        case 'j': {
            NSEvent *newEvent = [NSEvent eventWithCGEvent: CGEventCreateKeyboardEvent(NULL, 124, true)];
            [self overrideMessagesKeyDown: newEvent];
            break;
        }
        case '#': {
            id messageViewer = [[self performSelector:@selector(delegate)] performSelector:@selector(delegate)];
            [messageViewer performSelector:@selector(deleteMessages:) withObject:nil];
            break;
        }
        case 'c': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 45, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMessagesKeyDown: newEvent];
            break;
        }
        case 'r': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 15, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMessagesKeyDown: newEvent];
            break;
        }
        case 'f': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 3, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskShift);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMessagesKeyDown: newEvent];
            break;
        }
        case 'a': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 15, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskShift);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMessagesKeyDown: newEvent];
            break;
        }
        case '/': {
            CGEventRef cgEvent = CGEventCreateKeyboardEvent(NULL, 3, true);
            CGEventSetFlags(cgEvent, kCGEventFlagMaskCommand | kCGEventFlagMaskAlternate);
            NSEvent *newEvent = [NSEvent eventWithCGEvent: cgEvent];
            [self overrideMailKeyDown: newEvent];
            break;
        }
        default:
            [self overrideMessagesKeyDown:event];
            break;

    }
}

@end
